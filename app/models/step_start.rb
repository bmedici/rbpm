class StepStart < Step

  def color
    '#F8F087'
  end
  
  def run(current_run, current_action)
    
    # Gather variables as mentionned in the configuration
    param_set = params['set']
    if param_set.is_a? Hash
      param_set.each do |name, value|
        puts "        - set variable (#{name}) to (#{value})"
        current_run.set_var(name, value, self, current_action)
        end    
      end  

    # Finished
    return 0, "done"

  end

end
