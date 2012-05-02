# Remove transactions


class Job < ActiveRecord::Base
  #use_transactional_fixtures = false

  belongs_to :step
  has_many :actions, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  
  accepts_nested_attributes_for :vars
  after_initialize :init_context
  serialize :context, JSON
  
  #scope :latest_actions, includes(:actions)
  #scope :latest_actions, includes(:actions)
  scope :locked, where('NOT worker=""')
  scope :not_locked, where('worker=""')
  scope :not_completed, where(:completed_at => nil)
  scope :running, locked.not_completed
  scope :runnable, not_locked.not_completed.order(:id)
  scope :failed, where('errno <> 0')

  # scope :failsafe_find_in, lambda do |job_ids|
  #   where('id in ?', )
  # end
  
  scope :failsafe_find_in, lambda { |ids|
    where('id in (?)', ids)
    }
  
  

  @logger = nil
  @beanstalk_job = nil
  @prefix = ""

  
  def init_context
    self.context ||= {}
  end
  
  def status_image_path
    if (self.errno != 0)
      return '/images/clock_red.png'
    elsif self.completed_at.nil?
      return '/images/clock.png'
    else
      return '/images/accept.png'
    end
  end

  def init_vars_from_context!
    return unless self.context.is_a? Hash

    # Initial self.vars is empty
    vars = []
  
    # Initialize job vars from initial_vars
    self.context.each do |name, value|
      vars << Var.find_or_create_by_name(name.to_s, :step => nil, :action => nil, :value => value)
      #self.set_var(name, value, nil, nil)
    end
    
    # 
    self.vars = vars
  end

  def started_since
    return nil if self.started_at.nil?
    return Time.now - self.started_at
  end

  def timed_out?
    return false if self.started_at.nil?
    return started_since >= JOB_DEFAULT_RELEASE_TIME  
  end

  def set_var(name, value, step = nil, action = nil)
    var = self.vars.find_or_create_by_name(name.to_s, :step => step, :action => action, :value => value)
    var.update_attributes(:step => step, :action => action, :value => value)
    return var
  end
  
  def get_var(name)
    var = self.vars.find_by_name(name)
    return var.value unless var.nil?
  end
  
  def get_vars_hash
    #run_id = run.id unless run.nil?
    vars = {}
    self.vars.each do |var|
      vars[var.name.to_s] = var.value
    end
    return vars
  end
  
  def unlock!
    self.update_attributes(:completed_at => nil, :locked => false)
  end
    
  def evaluate(expression)
    # Dont' do any replacement if expression is not a string
    return expression unless expression.is_a? String

    # Make a local copy
    output = expression.clone

    # Replace constants
    ENV_CONSTANTS.each do |name, value|
      pattern = "!#{name.to_s}"
      #return value if (output == pattern)
      output.gsub!(pattern, value.to_s)
    end

    # Replace internal values
    random = ActiveSupport::SecureRandom.hex(16)
    output.gsub!("#jobid", self.id.to_s) unless self.id.nil?
    output.gsub!("#random", random)
    output.gsub!("#now", Time.now.strftime("%Y%m%d-%H%M%S"))

    # Replace job vars
    self.vars.each do |var|
      pattern = "$#{var.name.to_s}"
      #puts "comparing expression(#{expression}) with pattern (#{pattern}), data(#{var.data}) value(#{var.value}) name(#{var.name}) id(#{var.id})" 
      #return var.value if (output == pattern)
      output.gsub!(pattern, var.value.to_s)
    end

    # Return the final string
    return output
  end

  def use_logger(logger, prefix="")
    @logger = logger
    @prefix = "#{prefix}[j#{self.id}]\t"
  end

  def use_beanstalk_job(beanstalk_job)
    @beanstalk_job = beanstalk_job
  end

  def touch_beanstalk_job
    @beanstalk_job.touch unless @beanstalk_job.nil?
  end

  def start!
    log "#############################################################################"
    log "## STARTING JOB (j#{self.id}) FROM STEP (s#{self.step.id}) #{self.step.label}"
    log "#############################################################################"
    
    # Initialize initial context into vars, create as many job.var's as needed
    log "initializing job with context: #{self.context.to_json}"
    self.init_vars_from_context!
     
    # Start execution from job's first step
    log "running from step (s#{self.step.id})"

    return self.run_from(self.step)
  end
  
  def reset!
    # Remove all children
    self.vars.destroy_all
    self.actions.destroy_all
    self.init_vars_from_context!

    # Flag it as clean
    self.completed_at = nil
    self.started_at = nil
    self.errno = 0
    self.errmsg = ""
    self.worker = ""

    self.save!
  end

  protected

  def run_from(from_step)
    # Init
    raise "EXITING: run_from expects a starting step" if from_step.nil?
    
    # Pass logger, beanstalk job to step
    from_step.use_logger(@logger, "#{@prefix} [s#{from_step.id}]")
    from_step.use_beanstalk_job(@beanstalk_job)

    #################################
    ### RUNNING LOCAL STEP'S STUFF
    #################################

    # Preparing action
    action = self.actions.create(:step => from_step)
    log "s#{from_step.id}: type (#{from_step.type}), action (a#{action.id}), label (#{from_step.label})"

    # Validate step parameters
    if validation_error = from_step.validate_params?
      action.update_attributes(:errno => -1, :errmsg => "exiting: error with step parameters (#{validation_error})")
      raise Exceptions::JobFailedParamError, "validate_params failed (#{validation_error})"
      return
    end

    # Ping job
    log "s#{from_step.id}: touch job"
    self.touch_beanstalk_job
    
    # Run this step and close the action
    log "s#{from_step.id}: running step"
    begin
      errno, errmsg, locals = from_step.run(self, action)
      
    rescue Exceptions => exception
      log "s#{from_step.id}: EXCEPTION [#{errno}: #{errmsg}] raising JobFailedStepRaised"
      
      # Store return codes into action
      action.update_attributes(:errno => errno, :errmsg => errmsg)
      
      # End this step execution
      raise Exceptions::JobFailedStepRaised, "#{errno}: #{errmsg}"
    end      
    
    # No exception was raised, let's see what the return code is
    if errno.zero?
      # Return code is ok
      errmsg_short = errmsg.gsub(/\n/," ").gsub(/\r/," ")[0...100]
      log "s#{from_step.id}: returned [#{errno}: #{errmsg_short}]"

      # Store return codes into action
      action.update_attributes(:errno => errno, :errmsg => errmsg, :completed_at => Time.now)
    else
      # As step returned an error, just stop here too
      log "s#{from_step.id}: ERRROR [#{errno}: #{errmsg}] raising JobFailedStepRun"

      # Store return codes into action
      action.update_attributes(:errno => errno, :errmsg => errmsg)

      # Then interrupt the process
      raise Exceptions::JobFailedStepRun, "[#{errno}: #{errmsg}]"
    end
    
    # FIXME: let's assume that a failed run stops the whole process


    #################################
    ### FOLLOWING LINKS
    #################################
    
    # Stacking and sorting all links
    blocking_threads = [] 
    nonblocking_threads = [] 
    typed_links = from_step.links.includes(:next).group_by(&:type)
    
    # Handling LinkBlocker links
    typed_links['LinkBlocker'].each do |link|
      next if link.next_id.nil?
      next_step = link.next
      blocking_threads << Thread.new() {
        log "s#{from_step.id}: #{link.type} > thread executing (s#{next_step.id}) #{next_step.label}"
        self.run_from(next_step)
        log "s#{from_step.id}: thread ending for (s#{next_step.id}) #{next_step.label}"
        }
      # remove this link from the stack
    end unless typed_links['LinkBlocker'].nil?
    # FIXME
    typed_links['LinkBlocker'] = []
    
    # Handling LinkFork links
    typed_links['LinkFork'].each do |link|
      next if link.next_id.nil?
      next_step = link.next
      log "s#{from_step.id}: #{link.type} > pushing job (s#{next_step.id}) #{next_step.label}"
      
      # Get a "locals" key of :label as the label 
      job_label = nil
      job_label = locals[:label].to_s if context.is_a? Hash
      
      # Creating a new, standalone job
      job = Job.create(:step => next_step, :creator => "workerd.fork(j#{self.id}, s#{from_step.id})", :label => job_label, :context => locals)
      log "s#{from_step.id}:  - initial vars: locals.to_json"
      log "s#{from_step.id}:  - created job j#{job.id}"
      
      # Push this job onto the queue, and update job's bsid
      bs = Q.new
      bsid = bs.push_job(job)
      bs.close
      log "s#{from_step.id}:  - notified on queue bsid: #{bsid}"
      job.update_attributes(:bsid => bsid)

    end unless typed_links['LinkFork'].nil?
    # FIXME
    typed_links['LinkFork'] = []

    # Wait for blocking threads to complete
    log "s#{from_step.id}: waiting for (#{blocking_threads.size}) blocking threads"
    unless blocking_threads.size.zero?
      blocking_threads.map { |thread| thread.join }
    end

    # Ignoring LinkNever links
    # FIXME
    typed_links['LinkNever'] = []

    # Handling all other links
    typed_links.each do |type, link_stack|
      link_stack.each do |link|
        next if link.next_id.nil?
        next_step = link.next
        nonblocking_threads << Thread.new() {
          log "s#{from_step.id}: #{link.type} > thread executing (s#{next_step.id}) #{next_step.label}"
          self.run_from(next_step)
          log "s#{from_step.id}: thread ending for (s#{next_step.id}) #{next_step.label}"
          }
      end
      
    end
    
    # Wait for other threads to complete
    log "s#{from_step.id}: waiting for (#{nonblocking_threads.size}) non-blocking threads"
    unless nonblocking_threads.size.zero?
      nonblocking_threads.map { |thread| thread.join}
    end

    # Finished
    #log "s#{from_step.id}: completed"
  end

  def log(msg="")
    stamp = Time.now.strftime(LOGGING_TIMEFORMAT)
    @logger.info "#{stamp}\t#{@prefix}#{msg}" unless @logger.nil?
  end
  

end