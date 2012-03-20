namespace :jobs do

  desc "Start process forward from step"
  task :pop, [] => [:environment] do |t, args|
    # Init args
    #args.with_defaults(:start_step_id => nil)
    
    # Fetch the next runnable job
    job = Job.runnable.first
    if job.nil?
      puts "ENDING: nothing to do"
      exit
    end
    
    # Lock it right now
    job.update_attributes(:locked => Process.pid, :started_at => Time.now)
    
    # Run it
    # Parse args
    raise "EXITING: jobs:pop expects a starting step" if job.step.nil?

    puts
    puts "##############################################################################"
    puts "#### STANDALONE JOB (j#{job.id}) FROM STEP (s#{job.step.id}) #{job.step.label}"
    puts "##############################################################################"

    # Start the process execution on the root step
    initial_vars = nil
    #ret = job.run_with_vars(initial_vars)
    #ret = job.run_from(job.step)
    ret = job.run!

    # It's done, unlock it
    job.update_attributes(:locked => nil, :completed_at => Time.now)
    puts "ENDING sucessfully"
  end

end  
  
  