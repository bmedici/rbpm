class StepFailer < Step

  def color
    '#ffC070'
  end
  
  def shape
    :box
  end
  
  def run(current_job, current_action)
    # Starting
    log "StepFailer.start"
    
    # Raise an unhandled exception
    raise Exceptions::UnhandledException, "failing as expected"
    
    # Finished
    log "StepFailer.end failing as expected"
    return 1, "failed the perfect way"
  end
  
end