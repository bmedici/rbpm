class StepNoop < Step

  def color
    '#F6F6F6'
  end
  
  def shape
    :box
  end
  
  def run(current_job, current_action)
    log "StepNoop.run doing nothing as expected"
    return 0, "done nothing, and did it right"
  end
  
end