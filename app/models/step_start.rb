class StepStart < Step

  # def paramdef
  #   {
  #     :label_variable_name => { :description => "Set the current job label to a static value ok a job's variable value", :format => :json },
  #   }
  # end

  def color
    '#F8F087'
  end
  
  def run(current_job, current_action)
    # # Init
    # label_variable_name = self.pval(:label_variable_name)
    # 
    # # If provided, tag the current job with its new label
    # current_job.updat_attributes(:label_var => label_variable_name) unless label_variable_name.nil?
    # post_variables[field_name] = current_job.evaluate(expression)
    return 0, "StepStart done"
  end

end