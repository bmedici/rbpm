WAIT_DELAY = 1
namespace :jobs do

  desc "Start process forward from step"
  task :pop, [] => [:environment] do |t, args|
    # Init args
    #args.with_defaults(:start_step_id => nil)

    # Main loop
    puts "\e[H\e[2J"
    begin

      # Fetch the next runnable job
      print "waiting for a job to become runnable "
      STDOUT.flush
      job = nil

      begin
        job = Job.runnable.first(:lock => true)

        # If we got nothing, just wait some time
        if job.nil?
          print "."
          STDOUT.flush
          sleep WAIT_DELAY

        # If the query returned anything, quickly lock it
        else
          # Now try to get the lock on this record
          job.update_attributes(:locked => Process.pid, :started_at => Time.now)

          # And then double-check that we really own the lock
          job.reload
          if (job.locked != Process.pid)
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
      initial_vars = nil
      #ret = job.run_with_vars(initial_vars)
      #ret = job.run_from(job.step)
    
      begin
        ret = job.run!

      rescue Exceptions::JobFailedParamError => exception
        raise "EXITING: missing step parameter: #{exception.message}"

      rescue Exceptions::JobFailedStepRun => exception
        raise "EXITING: failed to run: #{exception.message}"

      else
        # It's done, unlock it, otherwise leave it like that
        job.update_attributes(:locked => nil, :completed_at => Time.now)
        puts "ENDING sucessfully"
      end

      # Just have a resr for 1s
      puts
      puts
      sleep 1
    end while true
  
  end

end