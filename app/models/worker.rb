class Worker
  @logger = nil
  @bs = nil
  @prefix = ""
  #@jobs_queue = QUEUE_DEFAULT
  @jobs_queue = QUEUE_JOBS
  #@current_beanstalk_message
  
  def initialize(hostname, pid)
    base = hostname.split('.')[0]
    @name = "#{base}-#{pid}"
    @bs = Q.new
  end
  
  def shutdown
    @bs.close
  end
  
  def use_logger(logger, prefix="")
    @logger = logger
    @prefix = "#{@prefix}#{@name}\t"
  end
  
  def name
    @name
  end
  
  def last_activity
    Time.now - self.updated_at unless self.updated_at.nil?
  end

  def seems_zombie?
    return last_activity > WORKERD_ZOMBIE_DELAY
  end
  
  # def status_image_path
  #   if (self.last_activity <= WORKERD_ZOMBIE_DELAY)
  #     return '/images/accept.png'
  #   elsif (self.jobs.size > 0)
  #     return '/images/clock.png'
  #   else
  #     return '/images/clock_red.png'
  #   end
  # end

  # def logjob(job, msg)
  #   log "[j#{job.id}] #{msg}" unless @job.nil?
  # end
  
  def poll_database
    log "worker#poll_database"
    
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
        log "database: found job [j#{job.id}]"
        job.update_attributes(:worker => @name, :started_at => Time.now)
        
        # Do the work on this job
        raise "EXITING: jobs:pop expects a starting step" if job.step.nil?

        # Start the process execution on the root step
        begin
          job.use_logger(@logger, @prefix)
          #job.use_logger(@logger, "#{@name} [j#{job.id}]")
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
  
  def handle_beanstalk_jobs
    log "worker#handle_beanstalk_jobs"
    
    # Announce the worker
    @bs.announce_worker(@name)
    log "announced worker [#{@name}]"
    
    # Bind on the jobs queue
    # FIXME

    # Main endless loop
    loop do
      # Reserve a job item to handle
      log "waiting for a job"
      j = @bs.reserve_job
      jdata = j.ybody
      log "received: #{jdata.to_json}"
      
      # Check for job id presence
      jid = jdata[:id]
      unless (jid.to_i)>0
        log "SKIPPING: job id ot found in message"
        j.bury
        next
      end

      # Read and flag the job in the database
      begin
        job = Job.find(jid)
        #or raise Exceptions::WorkerFailedJobNotfound("job (#{jid}) not found")
        job.update_attributes(:worker => @name, :started_at => Time.now)
        log "found and locked job [j#{job.id}]"
      rescue ActiveRecord::RecordNotFound
        log "SKIPPING: job [j#{jid}] not found in database"
        j.bury
        next
      end
      
      # Bury beanstalk' job, so that it's not redistributed in case of failure
      #j.bury

      #raise "EXITING: temporary stop"

      
      # Do the work on this job
      raise "EXITING: jobs:pop expects a starting step" if job.step.nil?

      # Start the process execution on the root step
      begin
        job.use_beanstalk_job(j)
        job.use_logger(@logger, @prefix)
        job.start!

      rescue Exceptions::JobFailedParamError => exception
        job.update_attributes(:worker => nil, :errno => -11 , :errmsg => exception.message)
        log "JOB [j#{job.id}] JOB ABORTED JobFailedParamError #{exception.message}"

      rescue Exceptions::JobFailedStepRun => exception
        job.update_attributes(:worker => nil, :errno => -12 , :errmsg => exception.message)
        log "JOB [j#{job.id}] JOB ABORTED JobFailedStepRun #{exception.message}"

      rescue Mysql2::Error => exception
        job.update_attributes(:worker => nil, :errno => -3 , :errmsg => exception.message)
        log "JOB [j#{job.id}] JOB ABORTED Mysql2::Error: #{exception.message}"

      rescue ActiveRecord::StatementInvalid => exception
        job.update_attributes(:worker => nil, :errno => -9 , :errmsg => exception.message)
        log "JOB [j#{job.id}] JOB ABORTED: ActiveRecord::StatementInvalid: #{exception.message}"

      rescue Exceptions => exception
        job.update_attributes(:worker => nil, :errno => -1 , :errmsg => exception.message)
        log "JOB [j#{job.id}] JOB ABORTED: #{exception.message}"

      else
        # It's done, unlock it, otherwise leave it like that
        job.update_attributes(:worker => nil, :completed_at => Time.now)
        j.delete
        log "job [j#{job.id}] completed and deleted"
        
      end
    end
  end
  
  protected
  
  def log(msg="")
    stamp = Time.now.strftime(LOGGING_TIMEFORMAT)
    @logger.info "#{stamp}\t#{@prefix}#{msg}" unless @logger.nil?
  end
  
end