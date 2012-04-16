#require 'daemons'

class Worker < ActiveRecord::Base
  has_many :jobs
  @logger = nil
  @prefix = ""
  
  def log_to(logger, prefix)
    @logger = logger
    @prefix = prefix
  end
  
  def last_activity
    Time.now - self.updated_at unless self.updated_at.nil?
  end

  def seems_zombie?
    return last_activity > WORKERD_ZOMBIE_DELAY
  end
  
  def status_image_path
    if (self.last_activity <= WORKERD_ZOMBIE_DELAY)
      return '/images/accept.png'
    elsif (self.jobs.size > 0)
      return '/images/clock.png'
    else
      return '/images/clock_red.png'
    end
  end

  # def logjob(job, msg)
  #   log "[j#{job.id}] #{msg}" unless @job.nil?
  # end
  
  def work
    log "starting"
    
    # Main endless loop
    loop do
        # Try to fetch a runnable job
        #logger.silence do
          job = Job.runnable.first(:lock => true)
        #end

        # If we got nothing, just wait some time and loop back
        if job.nil?
          # Touch the worker's record as a hearbeat
          #log "waiting for a job"
          self.touch
          
          # Wait a few seconds before polling again
          sleep WORKERD_POLL_DELAY
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