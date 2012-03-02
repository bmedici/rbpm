class Run < ActiveRecord::Base
  belongs_to :start_step, :class_name => 'Step'
  has_many :actions, :dependent => :destroy
  has_many :vars, :dependent => :destroy

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
  
end