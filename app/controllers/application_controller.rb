class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :parse_steps_yaml

  # def parse_steps_yaml
  #   @config = YAML::load(File.open("#{RAILS_ROOT}/config/step_attributes.yml"))
  # end

end