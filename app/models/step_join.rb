class StepJoin < Step

  def color
    '#B8D0DD'
  end
  
  def run(current_run, current_action)
    variable = 'last_hit'
    value = Time.now.to_s
    
    self.vars.find_or_create_by_name(variable, :value => value, :action => current_action, :run => current_run)
    return 0, "done"
  end
  
  def validate_params?
  end
  
end
