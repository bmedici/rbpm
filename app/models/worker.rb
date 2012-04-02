#require 'daemons'

class Worker < ActiveRecord::Base
  has_many :jobs
  
  def start
    # Main endless loop
    loop do
        # Try to fetch a runnable job
        job = Job.runnable.first(:lock => true)

        # If we got nothing, just wait some time and loop back
        if job.nil?
          #Rails.logger.info "PID [#{pid}]: no job"
          sleep WAIT_DELAY
          next
        end

        # Now try to get the lock on this record
        #Rails.logger.info "PID [#{pid}]: found job [j#{job.id}] to run"
        job.update_attributes(:worker => worker, :started_at => Time.now)
        sleep(5)
        #Rails.logger.info "PID [#{pid}]: terminated"
        job.update_attributes(:worker => nil, :completed_at => Time.now)
      
        # And then double-check that we really own the lock
        # job.reload
        # if (job.worker_id != worker.id)
        #   print "!"
        #   job = nil
        # end
    end
  end
  
end