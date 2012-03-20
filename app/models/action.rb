class Action < ActiveRecord::Base
  belongs_to :step
  belongs_to :job
  has_many :vars, :dependent => :destroy

  has_many :job_vars, :through => :job
  
  scope :latest, group(:step_id).order('id DESC')
  
  # def run
  #   #self.started_at = TIme.now
  #   #self.running = true
  #   self.save
  #   # Start working on this action
  #   
  #   #logger.info "  run_against(job_id: #{job.id})"
  #   
  #   # Make what has to be made on this step
  #   #logger.info "    wait 2 seconds"
  #   #sleep(2)
  #   #logger.info "    wait done"
  #   
  #   # Done!
  #   self.output = "finished step #{self.step_id} for job #{self.job_id}"
  #   self.completed_at = TIme.now
  #   #self.running = false
  #   self.save
  # end  
  # 
end