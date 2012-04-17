class StepMd5 < Step

  def paramdef
    {
    :file_to_hash => { :description => "Variable containing path to the file *", :format => :text, :lines => 2 },
    :variable_to_set => { :description => "Variable receiving the result", :format => :text, :lines => 2 },
    }
  end

  def color
  end
  
  def run(current_job, current_action)
    # Init
    file_to_hash = self.pval(:file_to_hash)
    variable_to_set = self.pval(:variable_to_set)
    
    # Check for run context
    log "StepMd5 starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?

    # Evaluate source file and trget variable
    #log "current_job: #{current_job.to_json}"
    log "vars: #{current_job.vars.to_json}"
    evaluated_file_to_hash = current_job.evaluate(file_to_hash)
    log "file_to_hash (#{file_to_hash}) > (#{evaluated_file_to_hash})"
    log "variable_to_set (#{variable_to_set})"
    return 22, "source file not found (#{file_to_hash}) > (#{evaluated_file_to_hash})" unless File.exists? evaluated_file_to_hash
    
    

    # Hash this filepath
    md5hash = Digest::MD5.hexdigest(File.read evaluated_file_to_hash)
    log "hashed: (#{md5hash})"
    
    # Save the result in a variable
    current_job.set_var(variable_to_set, md5hash, self, current_action)

    # Finished
    return 0, "md5 hash of (#{evaluated_file_to_hash}) is (#{md5hash})"
  end
  
  #private
  
  def validate_params?
    return :file_to_hash if self.pval(:file_to_hash).blank?
    return :variable_to_set if self.pval(:variable_to_set).blank?
    return false
  end
  
end
