class StepWindowize < Step
  
  def paramdef
    {
    #:vars => { :description => "Values (or variable references) fed into the request template", :format => :json },
    :path => { :description => "Value or variable containing path to tansform", :format => :text, :lines => 2 },
    :replace => { :description => "Base path to be replaced", :format => :text, :lines => 1 },
    :with => { :description => "String to replace the base path with", :format => :text, :lines => 2 },
    :variable_to_set => { :description => "Variable receiving the result", :format => :text, :lines => 2 },
    }
  end

  def color
    #'#F6F6F6'
  end
  
  def shape
    :box
  end
  
  def run(current_job, current_action)
    log "StepWindowize start"
    
    # Init
    path = self.pval(:path)
    replace = self.pval(:replace)
    with = self.pval(:with)
    variable_to_set = self.pval(:variable_to_set)
    
    # Evaluate source path
    #log "vars: #{current_job.vars.to_json}"
    evaluated_path = current_job.evaluate(path)
    
    # Remove base in path
    windows_path = path.gsub(/^#{evaluated_path}/, with).gsub("/","\/")
    
    # Save the result in a variable
    current_job.set_var(variable_to_set, windows_path, self, current_action)
    
    return 0, "built path (#{windows_path})"
    
    log "StepWindowize end"
    return 0, "done nothing, and did it right"
  end

  
  def validate_params?
    return :path if self.pval(:path).blank?
    return :replace if self.pval(:replace).blank?
    return :with if self.pval(:with).blank?
    return :variable_to_set if self.pval(:variable_to_set).blank?
    return false
  end
  
end