module JobsHelper
  
  def status_image_path(job)
    return '/images/clock_red.png' if !job.worker.nil?
    return '/images/clock.png' if job.completed_at.nil?
    return '/images/accept.png'
  end
  
  
  

end