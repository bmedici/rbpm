class StepExpectVariables < Step

  def paramdef
    {
    :vars => { :description => "Array of variables to be checked for presence", :format => :json },
    }
  end

  def color
    '#FFF4E3'
  end
  
  def run(current_job, current_action)
    # Init
    expected_variables = self.pval(:vars)

    # Expected variables is a plain array of variable names
    log "expected: #{expected_variables.join(', ')}"
    
    # Read variables in this run, we get a hash 
    available_variables = current_job.get_vars_hash.keys
    log "available: #{available_variables.join(', ')}"
    
    # Check that all expected ar available
    missing_variables = expected_variables - available_variables
    log "missing: #{missing_variables.join(', ')}"
    # puts "        - available_variables.size: #{available_variables.size}"
    # puts "        - expected_variables.size: #{expected_variables.size}"
    # puts "        - missing_variables.size: #{missing_variables.size}"
    # puts "        - missing2: #{missing2.join(', ')}"

    unless missing_variables.empty?
      return 1, "expected variables missing: #{missing_variables.join(', ')}"
    end
    
    # Finished
    return 0, "done"
  end

  def validate_params?
    return :vars unless self.pval(:vars).is_a? Hash
    return false
  end

end