class StepFileMove < Step

  def paramdef
    {
    :source => { :description => "File to move (use $var to grab a job variable)", :format => :text  },
    :target => { :description => "Target folder to drop this file", :format => :text  },
    }
  end


  def color
    '#C6B299'
  end
  
  def run(current_job, current_action)
    # Check for run context
    puts "        - StepFileMove starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?
    
    # EValuate source file and targt dir
    source = current_job.evaluate(self.pval(:source))
    target = current_job.evaluate(self.pval(:target))
    
    # Check for directory presence
    return 21, "source file not found (#{watch})" unless File.exists? source
    return 22, "target directory not found (#{target})" unless File.directory? target

    # Move the flie
    filesize = File.size(source)
    puts "        - moving (#{source}) file to (#{target}), total (#{filesize}) bytes"
    FileUtils.mv(source,  target)
    
    # Add detected filename to "locals" returned
    puts "        - StepFileMove end"
    return 0, "moved () bytes successfully "
  end
  
  #private
  
  def validate_params?
    return :source if self.pval(:source).blank?
    return :target if self.pval(:target).blank?
    return false
  end
  
end