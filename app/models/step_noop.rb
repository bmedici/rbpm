class StepNoop < Step

  def color
    '#F6F6F6'
  end
  
  def shape
    :box
  end
  
  def run(current_run, current_action)
    puts "        - StepNoop.run doing nothing as expected"
    return 0, "done nothing, and did it right"
  end
  
end
