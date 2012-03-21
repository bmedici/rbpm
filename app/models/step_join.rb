class StepJoin < Step

  def color
    '#B8D0DD'
  end
  
  def run(current_job, current_action)
    variable = 'last_hit'
    value = Time.now.to_s
    
    
    # Wait for my siblings
    
    
    self.vars.find_or_create_by_name(variable, :value => value, :action => current_action, :run => current_job)
    return 0, "done"
  end
  
end
