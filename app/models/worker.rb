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
          job.start!

        rescue Exceptions::JobFailedParamError => exception
          job.update_attributes(:worker => nil, :errno => -11 , :errmsg => exception.message)
          log "JOB [j#{job.id}] ABORTED JobFailedParamError #{exception.message}"

        rescue Exceptions::JobFailedStepRun => exception
          job.update_attributes(:worker => nil, :errno => -12 , :errmsg => exception.message)
          log "JOB [j#{job.id}] ABORTED JobFailedStepRun #{exception.message}"

        rescue Exceptions => exception
          job.update_attributes(:worker => nil, :errno => -1 , :errmsg => exception.message)
          log "JOB [j#{job.id}] ABORTED: #{exception.message}"

        else
          # It's done, unlock it, otherwise leave it like that
          job.update_attributes(:worker => nil, :completed_at => Time.now)
          log "job [j#{job.id}] completed"
        end

        # Just have a rest for 1s
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
    @logger.info "#{Time.now.strftime(LOGGING_TIMEFORMAT)} #{@prefix} #{msg}" unless @logger.nil?
  end
  
end