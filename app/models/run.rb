class Run < ActiveRecord::Base
  belongs_to :start_step, :class_name => 'Step'
  has_many :actions, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  
  #scope :latest_actions, includes(:actions)
  #scope :latest_actions, includes(:actions)

  def execute_step(step)
    # Init
    puts "- run (r#{self.id}) on step (s#{step.id}) #{step.label}"

    # Preparing action
    action = actions.create(:step => step)
    #action.active = true
    action.save

    # Validate step parameters
    if step.validate_params?
      puts "    - s#{step.id}: exiting: error with step parameters" 
      action.retcode = -1
      action.output = "exiting: error with step parameters"
      action.save
      return
    end

    # Run this step
    puts "    - s#{step.id}: created action (a#{action.id})"
    action.retcode, action.output = step.run(self, action)

    # Closing action
    action.completed_at = Time.now
    action.save
    
    # Read all vars to prepare context
    var = self.get_vars_hash

    # Loop through next links and follow them
    puts "    - s#{step.id}: step has (#{step.nexts.size}) next steps"
    threads = [] 
    #step.nexts.each do |next_step|
    step.links.each do |next_link|
      # Evaluate "condition" as ruby code
      puts "    - s#{step.id}: evaluating condition on link (l#{next_link.id}) to step (s#{next_link.next_id})"
      execute_next_step = false
      unless next_link.condition.blank?
        begin
          condition_return = eval(next_link.condition)
          execute_next_step = true if condition_return
        rescue Exception => e
          puts "    - s#{step.id}: exiting: error with condition on link (l#{next_link.id}) to step (s#{next_link.next_id})" 
          action.retcode = -2
          action.output = "exiting: condition error on link (l#{next_link.id}) to step (s#{next_link.next_id}): #{e.message}" 
          action.save
          return
        end
        puts "    - s#{step.id}: condition returns (#{condition_return})"
      end
      
      # Thread the next step if needed
      if (execute_next_step)
        # Fork for each of the links that passed the condition, create a new thread to run it
        threads << Thread.new() {
          # Read this next step
          next_step = Step.includes(:links).find(next_link.next_id)
          puts "    - s#{step.id}: thread executing (s#{next_step.id}) #{next_step.label}"

          # Recurse to this sub-step
          self.execute_step(next_step)
          puts "    - s#{step.id}: thread ending for (s#{next_step.id}) #{next_step.label}"
          }
        end

    end

    # Wait for each child process to complete
    puts "- s#{step.id}: waiting for children to finish"
    threads.map { |thread| thread.join}

    # Finished
    puts "- s#{step.id}: finished"
  end
  
  def set_var(name, value, step = nil, action = nil)
    var = self.vars.find_or_create_by_name(name.to_s, :value => value.to_s, :step => step, :action => action)
    var.value = value.to_s
    var.step = step
    var.action = action
    var.save
    return var
  end
  
  def get_var(name)
    #run_id = run.id unless run.nil?
    record = self.vars.find_by_name(name)
    return record[:value] unless record.nil?
  end
  
  protected
  
  def get_vars_hash
    #run_id = run.id unless run.nil?
    vars = {}
    self.vars.each do |v|
      vars[v.name.to_sym] = v.value
    end
    return vars
  end
  
end