class Run < ActiveRecord::Base
  belongs_to :start_step, :class_name => 'Step'
  has_many :actions, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  
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
      action.retcode = "-1"
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

    # Loop through next links and follow them
    puts "    - s#{step.id}: step has (#{step.nexts.size}) next steps"
    threads = [] 
    step.nexts.each do |next_step|
      # Evaluate conditions if any
      
      # Fork for each of the threads
      threads << Thread.new() {
        puts "    - s#{step.id}: threading to execute (s#{next_step.id}) #{next_step.label}"

        # Recurse to this sub-step
        self.execute_step(next_step)
        puts "    - s#{step.id}: thread ending for (s#{next_step.id})"
        }

    end

    # Wait for each child process to complete
    threads.map { |thread| thread.join}      

    # Finished
    puts "- s#{step.id}: finished"
  end
  
  def set_var(name, value, step = nil, action = nil)
    #step_id = step.id unless step.nil?
    #action_id = step.id unless action.nil?
    #action_id = action.id unless action.nil?
    #self.vars.find_or_create_by_name_and_run_id(name, run_id, :value => match.to_s, :action => action_id)
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
  
end