class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :parse_steps_yaml
  #before_filter :init_links_array

  # def parse_steps_yaml
  #   @config = YAML::load(File.open("#{RAILS_ROOT}/config/step_attributes.yml"))
  # end

  # def init_links_array
  #   @links = []
  # end
end