class StepWaiter < Step
  
  def paramdef
    {
      :time => { :description => "Seconds to wait", :format => :number, :lines => 1  },
    }
  end
    
  def color
    '#E6D5C1'
  end

  def shape
    :note
  end

  def run(current_job, current_action)
    # Init
    log "StepWaiter.run start"
    # Init
    delay = self.pval(:time).to_f
    
    # Execute
    log "waiting (#{delay}) seconds"
    sleep delay
    
    # Finalize
    log "StepWaiter.run end"
    return 0, "waited #{delay} seconds"
  end
  
  def validate_params?
    return :time unless is_numeric? self.pval(:time)
    return false
  end
  
end