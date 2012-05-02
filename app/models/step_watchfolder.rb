class StepWatchfolder < Step

  def paramdef
    {
      :watch => { :description => "Incoming folder to watch", :format => :text, :lines => 2  },
      :target => { :description => "Target folder to move the detected file", :format => :text, :lines => 2  },
      :delay => { :description => "Delay to wait when watching folder (seconds)", :format => :text, :lines => 1  },
    }
  end


  def color
    '#C6B299'
  end
  
  def run(current_job, current_action)
    # Init
    watch = self.pval(:watch)
    target = self.pval(:target)
    delay = self.pval(:delay).to_f

    # Delay is default unless specified
    delay = 0.5 if delay.zero?
    
    # Check for run context
    log "StepWatchfolder starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?
    
    # Evaluate source file and targt dir
    evaluated_watch = current_job.evaluate(watch)
    log "evaluated watch: #{evaluated_watch}"
    
    # Check for directory presence
    return 21, "watch directory not found (#{evaluated_watch})" unless File.directory? evaluated_watch

    # Wait for a file in the watchfolder
    filter_watch = "#{evaluated_watch}/*"
    log "watching with delay (#{delay}s) and filter (#{filter_watch})"
    begin
      # Try to detect a file
      first_file = Dir[filter_watch].first
      #first_file = Dir['/Users/bruno/web/rbpm/tmp/incoming'].first
      
      # If found, continue outside of this loop
      break unless first_file.nil?
      
      # Otherwise, wait before looping
      #log " - nothing"
      sleep delay

      # Touch job
      self.touch_beanstalk_job
    end while true

    # A file has been detected
    basename = File.basename(first_file)
    log "detected (#{basename})"

    # Compute target directory and filename    
    evaluated_target = current_job.evaluate(target)
    log "evaluated target: #{evaluated_target}"
    target_file = "#{evaluated_target}/#{File.basename(first_file)}"
    
    # Create the target directory if not found
    unless File.directory? evaluated_target
      log "making directory (#{evaluated_target})"
      begin
        FileUtils.mkdir_p(evaluated_target, :mode => 0777)
      rescue Exception => e
        msg = "uncaught exception: #{e.message}"
        log msg
        return 32, msg
      end
    end
      
    # Move file to target dir
    log "moving (#{first_file}) to (#{target_file})"
    begin
      FileUtils.mv(first_file, target_file)

    rescue Errno::EACCES
      msg = "file move: EACCES: access denied"
      log msg
      return 31, msg
    
    end
    
    # Prepare a new run and "fork" a thread to handle it
    #puts "        - setting :detected_file variable to (#{target_file})"
    #current_job.set_var(:detected_file, target_file, self, current_action)
    
    # Add detected filename to "locals" returned
    log "StepWatchfolder end"
    return 0, "detected (#{basename}) moved to (#{target_file})", {:detected_file => target_file, :label => basename}
  end
  
  #private
  
  def validate_params?
    return :watch if self.pval(:watch).blank?
    return :archive if self.pval(:target).blank?
    return false
  end
  
end