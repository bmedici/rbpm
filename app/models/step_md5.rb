class StepMd5 < Step

  def paramdef
    {
    :path_variable => { :description => "Variable containing path to the file", :format => :text },
    :result_variable => { :description => "Variable receiving the result", :format => :text },
    }
  end

  def color
  end
  
  def run(current_job, current_action)
    # Init
    path_variable = self.pval(:path_variable)
    path_variable = self.pval(:result_variable)
    
    # Check for run context
    puts "        - StepMd5 starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?

    # Get the variable containing the path to hash
    puts "        - variable containing path is #{path_variable}"
    filename_to_hash = current_job.get_var(path_variable)
    return 22, "can't fetch the value of this variable" if filename_to_hash.nil?

    puts "        - this variable points to #{filename_to_hash}"
    return 23, "can't find the file to hash in the filesystem" unless File.exists? filename_to_hash

    # Hash this filepath
    md5hash = Digest::MD5.hexdigest(File.read filename_to_hash)
    puts "        - hashed: (#{md5hash})"
    
    # Save the result in a variable
    current_job.set_var(:md5hash, md5hash, self, current_action)

    # Finished
    return 0, "md5 hash of (#{filename_to_hash}) is (#{md5hash})"
  end
  
  #private
  
  def validate_params?
    return :path_variable unless self.pval(:path_variable).is_a? Hash
    return :result_variable unless self.pval(:result_variable).is_a? Hash
    return false
  end
  
end
