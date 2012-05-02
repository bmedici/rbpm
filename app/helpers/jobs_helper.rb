module JobsHelper

  def job_status_badge(job, queued_job_ids = nil)
    # we have an error code
    if (job.errno != 0)            
      return badge(:error, "failed (error #{job.errno})", job.errmsg)
    end
      
    # the job has already completed
    if !job.completed_at.nil?    
      return badge(:success, "succeeded")
    end

    # # not completed, but we can guess the job has timed out
    # if job.timed_out?
    #   return badge(:warning, "timed out")
    # end

    # not completed, but not started neither, and we do have a queued status
    if job.started_at.nil? && (queued_job_ids.is_a?Array) && (queued_job_ids.include? job.id)
      return badge(:inverse, "queued")
    end

    # not completed, but not started neither, and we have no queued job array
    if job.started_at.nil?    
      return badge(nil, "stale")
    end
        
    # completed_at is nil, job has not timed out, thus it's waiintg
    return badge(:info, "locked")
  end
  
  def badge(klass, text, title = "")
    return content_tag(:span, text, :class => "badge badge-#{klass.to_s}", :title => title)
  end
  
end