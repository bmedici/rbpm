class StepNoop < Step

  def color
    '#FFF4E3'
  end
  
  def run
    puts "  == StepNoop.run doing nothing as expected"
  end
  
end
