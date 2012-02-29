class StepWaiter < Step
  
  def color
    '#E6D5C1'
  end

  def shape
    :note
  end

  def run
    # Init
    check_params
    puts "        - StepWaiter.run start"
    
    # Execute
    delay = params.to_f
    puts "        - waiting (#{delay}) seconds"
    sleep delay
    
    # Finalize
    puts "        - StepWaiter.run end"
    return 0, "waited #{delay} seconds"
  end
  
  private
  
  def check_params
    return 1 if is_numeric? params
    return false
  end
  
end