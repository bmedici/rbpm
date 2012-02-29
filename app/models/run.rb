class Run < ActiveRecord::Base
  belongs_to :start_step, :class_name => 'Step'
  has_many :actions, :dependent => :destroy

  def execute_step(step)
    # Init
    puts "- run (r#{self.id}) on step (s#{step.id}) #{step.label}"

    # Preparing action
    action = actions.create(:step => step)
    #action.active = true
    action.save

    # Run this step
    puts "    - action (a#{action.id}): running step (s#{self.id})"
    retcode, output = step.run

    # Closing action
    # End
    action.completed_at = Time.now
    #action.active = false
    action.retcode = retcode
    action.output = output
    action.save

    # Loop through next links and follow them
    puts "    - step (s#{step.id}) has (#{step.nexts.size}) next steps"
    threads = [] 
    step.nexts.each do |next_step|
      # Evaluate conditions if any
      
      # Fork for each of the threads
      threads << Thread.new() {
        puts "    - threading to execute step (s#{next_step.id}) (s#{next_step.id}) #{next_step.label}"

        # Recurse to this sub-step
        self.execute_step(next_step)
        puts "    - thread ending for step (s#{next_step.id})"
        }

    end

    # Wait for each child process to complete
    threads.map { |thread| thread.join}      

    # Finished
    puts "- finished with step (s#{step.id})"
  end
  
end