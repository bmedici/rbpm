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
    keys_list = current_job.get_var(keys_variable)
    return 21, "keys_variable (#{keys_variable}) points nowhere" if keys_list.nil?

    # Explode keys_variable to array
    keys = keys_list.split(',').map{|k| k.strip}
    log "keys_variable (#{keys_variable}) points to (#{keys.size}) keys (#{keys.join(', ')})"

    # Cumulate formats
    collected = []
    missing = []
    keys.each do |key|
      elements_for_this_key = matrix[key]
      if elements_for_this_key.is_a? Array
        log "key (#{key}) brings elements: (#{elements_for_this_key.join(', ')})"
        collected.concat(elements_for_this_key)
      else
        missing << key
        log "key (#{key}) is not found or not an array"
      end
    end
    
    # If we found some missing keys, just halt here
    return 22, "missing entries in matrix: #{missing. join(', ')}" unless missing.empty?

    # Save this result
    collected.uniq!
    collected_list = collected.join(', ')
    log "computed collected elements: #{collected_list}"
    current_job.set_var(result_variable, collected_list, self, current_action)

    # Finished
    return 0, "StepFormatsFromTargets: (#{keys.join(',')}) => (#{collected.join(',')})"

  end
  
  def validate_params?
    return :keys_variable if self.pval(:keys_variable).blank?
    return :result_variable if self.pval(:result_variable).blank?
    return :matrix unless self.pval(:matrix).is_a? Hash
    return false
  end

end