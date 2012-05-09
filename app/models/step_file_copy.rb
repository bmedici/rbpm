class StepFileCopy < Step

  def paramdef
    {
    :source => { :description => "File to copy (use $var to grab a job variable) *", :format => :text, :lines => 2   },
    :target => { :description => "Target folder to drop this file *" , :format => :text, :lines => 2   },
    }
  end


  def color
    '#C6B299'
  end
  
  def run(current_job, current_action)
    # Check for run context
    log "StepFileCopy start"
    return 11, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?
    
    # Evaluate source file and targt dir
    evaluated_source = current_job.evaluate(self.pval(:source))
    evaluated_target = current_job.evaluate(self.pval(:target))
    
    # Check for directory presence
    log "evaluated target: #{evaluated_target})"
    return 22, "target directory not found (#{evaluated_target})" unless File.directory? evaluated_target

    # Find and move the flie(s)
    moved_files = []
    log "listing files in evaluated source: #{evaluated_target}"
    Dir.glob(evaluated_source).each do |source_file|
      filesize = File.size(source_file)
      log "copying file: #{source_file} (size: #{filesize} bytes)"
      FileUtils.cp(source_file,  evaluated_target)
      moved_files << File.basename(source_file)
    end
    
    # If no file has been copied, we failed !
    return 23, "no file has beend moved!" if moved_files.empty?
    
    # Add detected filename to "locals" returned
    log "StepFileCopy end"
    return 0, "copied [#{moved_files.join(', ')}] to (#{evaluated_target})"
  end
  
  #private
  
  def validate_params?
    return :source if self.pval(:source).blank?
    return :target if self.pval(:target).blank?
    return false
  end
  
end