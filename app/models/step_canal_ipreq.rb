require 'rest_client'
require 'rexml/document'

class StepCanalIpreq < Step
  
  def paramdef
    {
    :postvars => { :description => "POST variables ($var for job's variables)", :format => :json },
    :remote => { :description => "Remote host address and credentials", :format => :json },
    :parse_xml => { :description => "Extract fields from XML response", :format => :json },
    :parse_json => { :description => "Extract fields from JSON response", :format => :json },
    }
  end

  def color
    '#B7E3C0'
  end
  
  def shape
    :note
  end
  
  def run(current_job, current_action)
  end
  
  def validate_params?
    return :postvars unless self.pval(:postvars).is_a? Hash
    return :remote unless self.pval(:remote).is_a? Hash
    return false
  end
  
end
