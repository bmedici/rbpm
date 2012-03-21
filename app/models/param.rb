class Param < ActiveRecord::Base
  belongs_to :step
  
  # def parse_as(format)
  #   case format
  #   when :yaml
  #     YAML::parse(self.value) rescue nil
  #   when :json
  #     JSON::parse(self.value) rescue nil
  #   else
  #     return p.value
  #   end
  # end
  
  def value_format
    # Try to parse JSON and format it
    json = JSON::parse(self.value) rescue nil
    return JSON.pretty_generate(json) unless json.nil?
    
    return self.value
  end
  
  def value_format=(val)
    self.value = val
  end
  
end