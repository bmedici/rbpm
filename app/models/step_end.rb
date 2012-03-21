class StepEnd < Step

  def color
    '#F8F087'
  end
  
  def run(current_job, current_action)
    return 0, "StepEnd done"
  end

end