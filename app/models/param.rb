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
  
end