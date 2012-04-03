class Job < ActiveRecord::Base
  belongs_to :step
  has_many :actions, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  belongs_to :worker
  
  accepts_nested_attributes_for :vars
  
  #scope :latest_actions, includes(:actions)
  #scope :latest_actions, includes(:actions)
  scope :locked, where('worker_id IS NOT NULL')
  scope :not_locked, where(:worker_id => nil)
  scope :not_completed, where(:completed_at => nil)
  scope :runnable, not_locked.not_completed.order(:id)
  scope :failed, where('errno<>0')

  @logger = nil
  @prefix = ""

  def context=(initial_vars)
    return unless initial_vars.is_a? Hash
    
    # Initialize job vars from initial_vars
    initial_vars.each do |name, value|
      self.set_var(name, value, nil, nil)
    end
  end

  def set_var(name, value, step = nil, action = nil)
    var = self.vars.find_or_create_by_name(name.to_s, :value => value.to_s, :step => step, :action => action)
    var.update_attributes(:value => value.to_s, :step => step, :action => action)
    return var
  end
  
  def get_var(name)
    record = self.vars.find_by_name(name)
    return record[:value] unless record.nil?
  end
  
  def get_vars_hash
    #run_id = run.id unless run.nil?
    vars = {}
    self.vars.each do |v|
      vars[v.name.to_s] = v.value
    end
    return vars
  end
  
  def unlock!
    self.update_attributes(:completed_at => nil, :locked => false)
  end
  
  def evaluate(expression)
    #return     varname = expression.to_s.slice(1..-1)

    if (expression.is_a? String) && (expression.chars.first == '$')
      varname = expression.to_s.slice(1..-1)
      return get_var(varname)
    end

    return expression
  end
    
  def log_to(logger, prefix)
    @logger = logger
    @prefix = prefix
  end

  def run!
    log
    log "######################################################################################"
    log "#### STARTING JOB (j#{self.id}) FROM STEP (s#{self.step.id}) #{self.step.label}"
    log "######################################################################################"

    return self.run_from(self.step)
  end
  
  protected
  
  def run_from(from_step)
    # Init
    raise "EXITING: run_from expects a starting step" if from_step.nil?
    from_step.log_to(@logger, "#{@prefix} [s#{from_step.id}]")

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
      log "s#{from_step.id}: returned [#{errno}: #{errmsg}]"

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
      
      # Prepare vars for the newly created job, extract label if passed
      if locals.is_a? Hash
        # Get a "locals" key of :label as the label 
        job_label = locals[:label].to_s
        # Create as many job.var's as needed
        job_vars = locals.map{|name, value| Var.new(:name => name, :value => value)} 
      else
        job_label = ""
        job_vars = []
      end
      
      # Creating a new, standalone job
      job = Job.create(:step => next_step, :creator => "job.LinkFork(j#{self.id}, s#{from_step.id})", :vars => job_vars, :label => job_label)
      log "s#{from_step.id}:  - initial vars: locals.to_json"
      log "s#{from_step.id}:  - created job j#{job.id}"

    end unless typed_links['LinkFork'].nil?
    # FIXME
    typed_links['LinkFork'] = []

    # Wait for blocking threads to complete
    log "s#{from_step.id}: waiting for (#{blocking_threads.size}) blocking threads"
    unless blocking_threads.size.zero?
      blocking_threads.map { |thread| thread.join }
    end

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
    log "s#{from_step.id}: completed"
    log
  end

  def log(msg="")
    @logger.info "#{Time.now.strftime(LOGGING_TIMEFORMAT)} #{@prefix} #{msg}" unless @logger.nil?
  end

end