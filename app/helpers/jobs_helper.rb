module JobsHelper

  def job_status_badge(job)
    # we have an error code
    if (job.errno != 0)            
      return badge(:error, "failed (error #{job.errno})", job.errmsg)
    end
      
    # the job has already completed
    if !job.completed_at.nil?    
      return badge(:success, "succeeded")
    end

    # completed_at is nil, but we can guess the job has timed out
    if job.timed_out?            
      return badge(:warning, "timed out")
    end
        
    # completed_at is nil, job has not timed out, thus it's waiintg
    return badge(:info, "waiting")
  end
  
  def badge(klass, text, title = "")
    return content_tag(:span, text, :class => "badge badge-#{klass.to_s}", :title => title)
  end
  
end