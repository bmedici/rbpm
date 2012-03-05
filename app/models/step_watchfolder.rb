class StepWatchfolder < Step

  def color
    '#C6B299'
  end
  
  def run(current_run, current_action)
    # Check for run context
    puts "        - StepWatchfolder starting"
    return 21, "depends on the run context to gather variables, no valid current_run given" if current_run.nil?
    
    # Check for directory presence
    return 21, "incoming directory not found (#{self.params['incoming']})" unless File.directory? self.params['incoming'].to_s
    return 22, "archive directory not found (#{self.params['archive']})" unless File.directory? self.params['archive'].to_s
    
    # Delay is default unless specified
    delay = self.params['delay'].to_i
    delay = 0.5 if delay.zero?

    # Wait for a file in the watchfolder
    filter_incoming = "#{self.params['incoming']}/*"
    puts "        - watching with delay (#{delay}s) and filter (#{filter_incoming})"
    begin
      # Try to detect a file
      first_file = Dir[filter_incoming].first
      #first_file = Dir['/Users/bruno/web/rbpm/tmp/incoming'].first
      
      # If found, continue outside of this loop
      break unless first_file.nil?
      
      # Otherwise, wait before looping
      puts "        - nothing"
      sleep delay
    end while true
      
    # A file has been detected, move it to the archive dir
    puts "        - detected (#{File.basename(first_file)})"
    target_file = "#{self.params['archive']}/#{File.basename(first_file)}"
    FileUtils.mv(first_file,  target_file)
    puts "        - moved to (#{target_file})"
    
    # Add this new filemane to the session
    current_run.set_var(:detected_file, target_file, self, current_action)

    # Finalize
    puts "        - StepWatchfolder end"
    return 0, "done"
  end
  
  #private
  
  def validate_params?
    return 11 if self.params['incoming'].blank?
    return 12 if self.params['archive'].blank?
    return false
  end
  
end