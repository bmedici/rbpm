class StepWaiter < Step
  
  def color
    '#E6D5C1'
  end

  def shape
    :note
  end

  def run(current_run, current_action)
    # Init
    puts "        - StepWaiter.run start"
    
    # Execute
    delay = params['time'].to_f
    puts "        - waiting (#{delay}) seconds"
    sleep delay
    
    # Finalize
    puts "        - StepWaiter.run end"
    return 0, "waited #{delay} seconds"
  end
  
  def validate_params?
    return 1 unless is_numeric? params['time']
    return false
  end
  
end