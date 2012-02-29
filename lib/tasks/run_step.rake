START_STEP_ID = 16

desc "Start process"
task :run_step => :environment do
  # Find root step
  root_step = Step.find(START_STEP_ID)
  
  # Create a new run
  puts "==== create_run from root_step (#{root_step.id}) #{root_step.label}"
  run = Run.new(:step => root_step)
  
  
  # End
  run.completed_at = Time.now
  run.save
  
end


def run_step(step)
  # Init
  puts "==== run_step (#{step.id}) #{step.label}"

  # Run root step
  step.run
  
  # Loop through next links and follow them
  step.nexts.each do |nexty|
    # Init
    puts "  == run_next (#{step.id}) => (#{nexty.id}) #{nexty.label}"
    
    # Evaluate conditions if any
    
    # Recurse to this sub-step
    run_step(nexty)
  end

  # Finished
  puts "==== run_step end (#{step.id}) #{step.label}"
end
