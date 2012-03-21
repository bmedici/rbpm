class StepSetVariables < Step

  def paramdef
    {
      :set_vars => { :description => "Set variables in current job", :format => :json },
    }
  end

  def color
    '#FFF4E3'
  end
  
  def run(current_job, current_action)
    
    # Gather variables as mentionned in the configuration
    set_vars = self.pval(:set_vars)
    
    
    if set_vars.is_a? Hash
      set_vars.each do |name, value|
        puts "        - set variable (#{name}) to (#{value})"
        current_job.set_var(name, value, self, current_action)
        end    
      end  

    # Finished
    return 0, "StepSetVariables done"

  end
  
  def validate_params?
    return :set_vars unless self.pval(:set_vars).is_a? Hash
    return false
  end

end