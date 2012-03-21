class StepWaiter < Step
  
  def paramdef
    {
      :time => { :description => "Seconds to wait", :format => :number  },
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
    puts "        - StepWaiter.run start"
    # Init
    delay = self.pval(:time).to_f
    
    # Execute
    puts "        - waiting (#{delay}) seconds"
    sleep delay
    
    # Finalize
    puts "        - StepWaiter.run end"
    return 0, "waited #{delay} seconds"
  end
  
  def validate_params?
    return :time unless is_numeric? self.pval(:time)
    return false
  end
  
end