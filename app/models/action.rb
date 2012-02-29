class Action < ActiveRecord::Base
  belongs_to :step
  belongs_to :run
  
  def run
    #self.started_at = TIme.now
    self.running = true
    self.save
    # Start working on this action
    
    #logger.info "  run_against(job_id: #{job.id})"
    
    # Make what has to be made on this step
    #logger.info "    wait 2 seconds"
    #sleep(2)
    #logger.info "    wait done"
    
    # Done!
    self.output = "finished step #{self.step_id} for job #{self.job_id}"
    self.completed_at = TIme.now
    self.running = false
    self.save
  end  
  
end