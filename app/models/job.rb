class Job < ActiveRecord::Base
  belongs_to :step
  has_many :actions, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  
  accepts_nested_attributes_for :vars
  
  @step
  
  #scope :latest_actions, includes(:actions)
  #scope :latest_actions, includes(:actions)
  scope :not_locked, where('locked is NULL or NOT locked')
  scope :not_completed, where(:completed_at => nil)
  scope :runnable, not_locked.not_completed.order(:id)

  def context=(initial_vars)
    return unless initial_vars.is_a? Hash
    
    # Initialize job vars from initial_vars
    initial_vars.each do |name, value|
      self.set_var(name, value, nil, nil)
    end
  end

  def run!
    self.run_from(self.step)
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
    self.update_attributes(:completed_at => nil, :locked => nil)
  end
  
  
  
  protected

  def run_from(step)
    # Init
    # Parse args
    raise "EXITING: run_from expects a starting step" if step.nil?
    puts "JOB (j#{self.id}) on step (s#{step.id}) #{step.label}"

    #################################
    ### RUNNING LOCAL STEP'S STUFF
    #################################

    # Preparing action
    action = self.actions.create(:step => step)
    action.save

    # Validate step parameters
    if step.validate_params?
      puts "    - s#{step.id}: EXITING: ERROR WITH STEP PARAMETERS" 
      action.retcode = -1
      action.output = "exiting: error with step parameters"
      action.save
      return
    end

    # Run this step and close the action
    puts "    - s#{step.id}: running step in action (a#{action.id})"
    action.retcode, action.output = step.run(self, action)
    action.completed_at = Time.now
    action.save
    
    # FIXME: let's assume that a failed run stops the whole process
    unless action.retcode.zero?
      puts "    - s#{step.id}: EXITING: RUN FAILED AND RETURNED (#{action.retcode}) #{action.output}" 
      return
    end

    #################################
    ### FOLLOWING LINKS
    #################################
    
    # Stacking and sorting all links
    blocking_threads = [] 
    nonblocking_threads = [] 
    # typed_links = {}
    # step.links.includes(:next).map do |link|
    #   typed_links[link.type] ||= []
    #   typed_links[link.type] << link
    # end

    typed_links = step.links.includes(:next).group_by(&:type)
    #puts "    - s#{step.id}: step has links of types: #{typed_links.keys.join(', ')}"
    
    # Handling LinkBlocker links
    typed_links['LinkBlocker'].each do |link|
      blocking_threads << Thread.new() {
        next_step = link.next
        puts "    - s#{step.id} (#{link.type}): thread executing (s#{next_step.id}) #{next_step.label}"
        self.run_from(next_step, nil)
        puts "    - s#{step.id}: thread ending for (s#{next_step.id}) #{next_step.label}"
        }
      # remove this link from the stack
    end unless typed_links['LinkBlocker'].nil?
    # FIXME
    typed_links['LinkBlocker'] = []
    
    # Handling LinkFork links
    typed_links['LinkFork'].each do |link|
      next_step = link.next
      puts "    - s#{step.id} (#{link.type}): pushing job (s#{next_step.id}) #{next_step.label}"
      
      # Duplicate this job's vars
      initial_vars = []
      self.vars.each do |v|
        initial_vars << Var.new(:name => v.name, :value => v.value)
      end
      
      # Creating new standalone job
      job = Job.create(:step => next_step, :creator => "job.LinkFork(j#{self.id}, s#{step.id})", :vars => initial_vars)
    end unless typed_links['LinkFork'].nil?
    # FIXME
    typed_links['LinkFork'] = []

    # Wait for blocking threads to complete
    puts "    - s#{step.id}: blocking_threads.size=#{blocking_threads.size}"
    unless blocking_threads.size.zero?
      puts "    - s#{step.id}: waiting for blocking threads to complete"
      blocking_threads.map { |thread| thread.join}
    end

    # Handling all other links
    typed_links.each do |type, link_stack|
      link_stack.each do |link|
        nonblocking_threads << Thread.new() {
          next_step = link.next
          puts "    - s#{step.id}: #{link.type}: thread executing (s#{next_step.id}) #{next_step.label}"
          self.run_from(next_step)
          puts "    - s#{step.id}: thread ending for (s#{next_step.id}) #{next_step.label}"
          }
      end
      
    end
    
    # Wait for other threads to complete
    unless nonblocking_threads.size.zero?
      puts "    - s#{step.id}: waiting for non-blocking threads to finish"
      nonblocking_threads.map { |thread| thread.join}
    end

    # Finished
    puts "    - s#{step.id}: finished"
    return action.retcode, action.output
  end

end