class StepFailer < Step

  def color
    '#ffC070'
  end
  
  def shape
    :box
  end
  
  def run(current_job, current_action)
    log "StepFailer.run failing as expected"
    return 1, "failed the perfect way"
  end
  
end