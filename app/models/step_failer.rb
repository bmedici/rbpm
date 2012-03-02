class StepFailer < Step

  def color
    '#ffC070'
  end
  
  def shape
    :box
  end
  
  def run(current_run, current_action)
    puts "        - StepFailer.run failing as expected"
    return 1, "failed the perfect way"
  end
  
end
