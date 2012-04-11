class StepFormatsFromTargets < Step

  def paramdef
    {
      :keys_variable => { :description => "Variable providing keys to keep", :format => :text, :lines => 1 },
      :result_variable => { :description => "Variable to receive collected elements", :format => :text, :lines => 1 },
      #:targets => { :description => "Target list or variable containing targets to build", :format => :json },
      :matrix => { :description => "Formats list to build for each target", :format => :json },
    }
  end

  def color
    '#FFF4E3'
  end
  
  def run(current_job, current_action)

    # Gather variables as mentionned in the configuration
    keys_variable = self.pval(:keys_variable)
    result_variable = self.pval(:result_variable)
    matrix = self.pval(:matrix)
    
    # Check for key list
    keys = current_job.get_var(keys_variable)
    return 21, "keys_variable (#{keys_variable}) points nowhere" if keys.nil?

    # Cumulate formats
    log "keys_variable (#{keys_variable}) points to (#{keys.size}) keys (#{keys.join(', ')})"
    
    collected = []
    keys.each do |key|
      elements_for_this_key = matrix[key]
      log "key (#{key}) brings elements: (#{elements_for_this_key.join(', ')})"
      collected.concat(elements_for_this_key)
    end
    collected.uniq!

    # Save this result
    log "computed collected elements: #{collected.join(', ')}"
    current_job.set_var(result_variable, collected, self, current_action)

    # Finished
    return 0, "StepFormatsFromTargets done"

  end
  
  def validate_params?
    return :keys_variable if self.pval(:keys_variable).blank?
    return :result_variable if self.pval(:result_variable).blank?
    return :matrix unless self.pval(:matrix).is_a? Hash
    return false
  end

end