class StepNoop < Step

  def color
    '#F6F6F6'
  end
  
  def shape
    :box
  end
  
  def run
    puts "        - StepNoop.run doing nothing as expected"
    return 1, "done nothing, and did it right"
  end
  
end
