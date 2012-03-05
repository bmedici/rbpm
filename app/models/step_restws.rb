require 'rest_client'
require 'rexml/document'

class StepRestws < Step

  def color
    '#B7E3C0'
  end
  
  def shape
    :note
  end
  
  def run(current_run, current_action)
  
  end
  
  #private
  
  def validate_params?

    return false
  end
  
end
