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

    # Evaluate source file and targt dir
    evaluated_file_to_hash = current_job.evaluate(file_to_hash)
    log "evaluated file_to_hash: #{evaluated_file_to_hash}"

    # Get the variable containing the path to hash
    log "variable containing path is #{path_variable}"
    filename_to_hash = current_job.get_var(path_variable)
    return 22, "can't fetch the value of this variable" if evaluated_file_to_hash.nil?

    log "this variable points to #{evaluated_file_to_hash}"
    return 23, "can't find the file to hash in the filesystem" unless File.exists? evaluated_file_to_hash

    # Hash this filepath
    md5hash = Digest::MD5.hexdigest(File.read filename_to_hash)
    log "hashed: (#{md5hash})"
    
    # Save the result in a variable
    current_job.set_var(variable_to_set, md5hash, self, current_action)

    # Finished
    return 0, "md5 hash of (#{filename_to_hash}) is (#{md5hash})"
  end
  
  #private
  
  def validate_params?
    return :file_to_hash if self.pval(:file_to_hash).blank?
    return :variable_to_set if self.pval(:variable_to_set).blank?
    return false
  end
  
end
