WAIT_DELAY = 1

desc "Start a worker process to handle jobs"
task :worker, [] => [:environment] do |t, args|
  # Init
  STDOUT.sync = true
  puts "\e[H\e[2J"
  
  # Main loop
  begin

    # Register worker (in the main loop to be sure we are created again if deleted meanwhile)
    pid = Process.pid
    hostname = `hostname`.chomp
    worker = Worker.find_or_create_by_hostname_and_pid(hostname, pid)
    puts "registered as worker ##{worker.id} running with pid ##{pid}"

    # Fetch the next runnable job
    puts "waiting for a job to become runnable "
    job = nil

    begin
      job = Job.runnable.first(:lock => true)

      # If we got nothing, just wait some time
      if job.nil?
        print "."
        sleep WAIT_DELAY

      # If the query returned anything, quickly lock it
      else
        # Now try to get the lock on this record
        job.update_attributes(:worker => worker, :started_at => Time.now)

        # And then double-check that we really own the lock
        job.reload
        if (job.worker_id != worker.id)
          print "!"
          job = nil
        end

      end
    end while job.nil?
    
    # Run it
    # Parse args
    raise "EXITING: jobs:pop expects a starting step" if job.step.nil?
    puts
    puts "##############################################################################"
    puts "#### RUNNING JOB (j#{job.id}) FROM STEP (s#{job.step.id}) #{job.step.label}"
    puts "##############################################################################"

    # Start the process execution on the root step
    begin
      ret = job.run!

    rescue Exceptions::JobFailedParamError => exception
      msg = "JobFailedParamError: #{exception.message}"
      job.updated_attributes(:worker => nil, :errcode => -11 , :errmsg => msg)
      raise "EXITING: #{msg}"

    rescue Exceptions::JobFailedStepRun => exception
      msg = "JobFailedStepRun: #{exception.message}"
      job.updated_attributes(:worker => nil, :errcode => -12 , :errmsg => msg)
      raise "EXITING: #{msg}"

    rescue Exceptions => exception
      msg = "Exception: #{exception.message}"
      job.updated_attributes(:worker => nil, :errcode => -1 , :errmsg => msg)
      raise "EXITING: #{msg}"

    else
      # It's done, unlock it, otherwise leave it like that
      job.update_attributes(:worker => nil, :completed_at => Time.now)
      puts "ENDING sucessfully"
    end

    # Just have a resr for 1s
    job.touch
    puts
    puts
    sleep 1
  end while true

end