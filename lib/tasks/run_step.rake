START_STEP_ID = 16

desc "Start process"
task :run_step => :environment do
  # Find root step
  root_step = Step.find(START_STEP_ID)
  
  # Create a new run
  puts "##############################################################################"
  puts "#### STARTING RUN WITH ROOT STEP (s#{root_step.id}) #{root_step.label}"
  puts "##############################################################################"
  run = Run.new(:start_step => root_step)
  run.save
  
  # Start the process execution on the root step
  run.execute_step(root_step)
  
  # End
  run.completed_at = Time.now
  run.save
end