class Var < ActiveRecord::Base
  belongs_to :job
  belongs_to :action
  belongs_to :step
    
  def value=(v)
    if (v.is_a? Hash) || (v.is_a? Array)
      self.data = v.to_json
      self.json = true
    else
      self.data = v.to_s
      self.json = false
    end
    
  end
  
  def value
    return self.json ? JSON::parse(self.data) : self.data.to_s
  end
  
  def pretty_value
    return JSON.pretty_generate(self.value)
  end
  
end
