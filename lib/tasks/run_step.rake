#START_STEP_ID = 16

desc "Start process"
task :run_step, [:start_step_id] => [:environment] do |t, args|
  # Init args
  #args.with_defaults(:start_step_id => nil)  
  
  # Parse args
  start_step_id =  args[:start_step_id].to_i
  raise "exiting: you must provide the starting step (ex: run_step[42])" if start_step_id.zero?

  # Find this step
  root_step = Step.find(start_step_id)
  raise "exiting: cannot find step (s#{start_step_id})" if root_step.nil?

  # Create a new run
  run = Run.new(:start_step => root_step)
  run.save
  puts "##############################################################################"
  puts "#### STARTING RUN (r#{run.id}) FROM STEP (s#{root_step.id}) #{root_step.label}"
  puts "##############################################################################"
  
  # Start the process execution on the root step
  run.execute_step(root_step)
  
  # End
  run.completed_at = Time.now
  run.save
end