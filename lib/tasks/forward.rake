desc "Start process forward from step"
task :run_from, [:step_id] => [:environment] do |t, args|
  # Init args
  #args.with_defaults(:start_step_id => nil)  
  
  # Parse args
  step_id =  args[:step_id].to_i
  raise "exiting: you must provide the starting step (ex: run_from[42])" if step_id.zero?

  # Find this step
  step = Step.find(step_id)
  raise "exiting: cannot find step (s#{step_id})" if step.nil?

  # Create a dedicated run
  initial_vars = {
    :creator, "manual (rake task)",
    :timestamp, Time.now.to_s
    }
  job = Job.new(:step => step, :test => 6, :vars => initial_vars)
  #job.start_from(step, initial_vars)

  #job.run_from(step, initial_vars)

end