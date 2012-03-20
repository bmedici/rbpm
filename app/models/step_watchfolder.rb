class StepWatchfolder < Step

  def paramdef
    {
      :watch => { :description => "Incoming folder to watch", :format => :text  },
      :target => { :description => "Target folder to drop the detected", :format => :text  },
      :delay => { :description => "Delay to wait when watching folder (seconds)", :format => :text  },
    }
  end


  def color
    '#C6B299'
  end
  
  def run(current_job, current_action)
    # Init
    watch = self.pval(:watch)
    target = self.pval(:target)
    
    # Check for run context
    puts "        - StepWatchfolder starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?
    
    # Check for directory presence
    return 21, "watch directory not found (#{watch})" unless File.directory? watch
    return 22, "target directory not found (#{target})" unless File.directory? target
    
    # Delay is default unless specified
    delay = self.params['delay'].to_i
    delay = 0.5 if delay.zero?

    # Wait for a file in the watchfolder
    filter_watch = "#{watch}/*"
    puts "        - watching with delay (#{delay}s) and filter (#{filter_watch})"
    begin
      # Try to detect a file
      first_file = Dir[filter_watch].first
      #first_file = Dir['/Users/bruno/web/rbpm/tmp/incoming'].first
      
      # If found, continue outside of this loop
      break unless first_file.nil?
      
      # Otherwise, wait before looping
      puts "        - nothing"
      sleep delay
    end while true
      
    # A file has been detected, move it to the target dir
    puts "        - detected (#{File.basename(first_file)})"
    target_file = "#{target}/#{File.basename(first_file)}"
    puts "        - moving file to (#{target_file})"
    FileUtils.mv(first_file,  target_file)
    
    # Prepare a new run and "fork" a thread to handle it
    puts "        - setting :detected_file variable to (#{target_file})"
    current_job.set_var(:detected_file, target_file, self, current_action)

    # Finalize
    puts "        - StepWatchfolder end"
    return 0, "done"
  end
  
  #private
  
  def validate_params?
    return 11 if self.pval(:watch).blank?
    return 12 if self.pval(:archive).blank?
    return false
  end
  
end