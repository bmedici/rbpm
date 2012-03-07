class StepSetVariable < Step

  def color
    '#FFF4E3'
  end
  
  def run(current_run, current_action)
    
    # Gather variables as mentionned in the configuration
    if params.is_a? Hash
      params.each do |name, value|
        puts "        - set variable (#{name}) to (#{value})"
        current_run.set_var(name, value, self, current_action)
        end    
      end  

    # Finished
    return 0, "done"

  end

end
