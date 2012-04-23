class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :parse_steps_yaml
  #before_filter :init_links_array
  helper_method :flash_class

  # def parse_steps_yaml
  #   @config = YAML::load(File.open("#{RAILS_ROOT}/config/step_attributes.yml"))
  # end

  # def init_links_array
  #   @links = []
  # end
  
  def flash_class(level)
     case level
     when :notice then "info"
     when :error then "error"
     when :alert then "warning"
     end
   end
end