class StepFileMove < Step

  def paramdef
    {
    :source => { :description => "File to move (use $var to grab a job variable) *", :format => :text, :lines => 2   },
    :target => { :description => "Target folder to drop this file *" , :format => :text, :lines => 2   },
    }
  end


  def color
    '#C6B299'
  end
  
  def run(current_job, current_action)
    # Check for run context
    log "StepFileMove starting"
    return 11, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?
    
    # Evaluate source file and targt dir
    evaluated_source = current_job.evaluate(self.pval(:source))
    log "evaluated source: #{evaluated_source}"
    evaluated_target = current_job.evaluate(self.pval(:target))
    log "evaluated target: #{evaluated_target}"
    
    # Check for directory presence
    return 21, "source file not found (#{evaluated_source})" unless File.exists? evaluated_source
    return 22, "target directory not found (#{evaluated_target})" unless File.directory? evaluated_target

    # Move the flie
    filesize = File.size(source)
    log "moving (#{evaluated_source}) file to (#{evaluated_target}), total (#{filesize}) bytes"
    FileUtils.mv(source,  target)
    
    # Add detected filename to "locals" returned
    log "StepFileMove end"
    return 0, "moved (#{evaluated_source}) file to (#{evaluated_target}), total (#{filesize}) bytes"
  end
  
  #private
  
  def validate_params?
    return :source if self.pval(:source).blank?
    return :target if self.pval(:target).blank?
    return false
  end
  
end