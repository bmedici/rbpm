class StepMd5 < Step

  def color
  end
  
  def run(current_run, current_action)
    # Check for run context
    puts "        - StepMd5 starting"
    return 21, "depends on the run context to gather variables, no valid current_run given" if current_run.nil?

    # Get the variable containing the path to hash
    puts "        - variable containing path is #{self.params['variable']}"
    filename_to_hash = current_run.get_var(self.params['variable'])
    return 22, "can't fetch the value of this variable" if filename_to_hash.nil?

    puts "        - variable points to #{filename_to_hash}"
    return 23, "can't find the file to hash in the filesystem" unless File.exists? filename_to_hash

    # Hash this filepath
    md5hash = Digest::MD5.hexdigest(File.read filename_to_hash)
    puts "        - hashed: (#{md5hash})"
    
    # Save the result in a variable
    current_run.set_var(:md5hash, md5hash, self, current_action)

    # Finished
    return 0, "md5 hash of (#{filename_to_hash}) is (#{md5hash})"
  end
  
  #private
  
  def validate_params?
    return 11 if self.params['variable'].blank?
    return false
  end
  
end
