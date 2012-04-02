#require 'daemons'

class Worker < ActiveRecord::Base
  has_many :jobs
  @logger = nil
  @prefix = ""
  
  def log_to(logger, prefix)
    @logger = logger
    @prefix = prefix
  end
  
  # def logjob(job, msg)
  #   log "[j#{job.id}] #{msg}" unless @job.nil?
  # end
  
  def work
    log "starting"
    
    # Main endless loop
    loop do
        # Try to fetch a runnable job
        job = Job.runnable.first(:lock => true)

        # If we got nothing, just wait some time and loop back
        if job.nil?
          #log "waiting for a job"
          sleep WAIT_DELAY
          next
        end

        # Now try to get the lock on this record
        log "found job [j#{job.id}]"
        job.update_attributes(:worker => self, :started_at => Time.now)
        
        # Do the work on this job
        raise "EXITING: jobs:pop expects a starting step" if job.step.nil?

        # Start the process execution on the root step
        begin
          job.log_to(@logger, "#{@prefix} [j#{job.id}]")
          job_retcode, job_output = job.run!

        rescue Exceptions::JobFailedParamError => exception
          msg = "JobFailedParamError: #{exception.message}"
          job.updated_attributes(:worker => nil, :errcode => -11 , :errmsg => msg)
          log "EXITING: #{msg}"

        # rescue Exceptions::JobFailedStepRun => exception
        #   msg = "JobFailedStepRun: #{exception.message}"
        #   job.updated_attributes(:worker => nil, :errcode => -12 , :errmsg => msg)
        #   raise "EXITING: #{msg}"
        # 
        # rescue Exceptions => exception
        #   msg = "Exception: #{exception.message}"
        #   job.updated_attributes(:worker => nil, :errcode => -1 , :errmsg => msg)
        #   raise "EXITING: #{msg}"

        else
          # It's done, unlock it, otherwise leave it like that
          job.update_attributes(:worker => nil, :completed_at => Time.now)
          log "job [j#{job.id}] returned [#{job_retcode}] #{job_output}"
        end

        # Just have a rest for 1s
        job.touch
        sleep 1
        
        # Work done, update all that stuff
        job.update_attributes(:worker => nil, :completed_at => Time.now)
      
        # And then double-check that we really own the lock
        # job.reload
        # if (job.worker_id != worker.id)
        #   print "!"
        #   job = nil
        # end
    end
  end
  
  protected
  
  def log(msg="")
    @logger.info "#{@prefix} #{msg}" unless @logger.nil?
  end
  
end