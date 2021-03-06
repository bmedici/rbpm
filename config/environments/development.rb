Rbpm::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  
  #config.cache_classes = true
  # has to be TRUE because of thrad usage

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  #config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Enable threaded mode
  #config.threadsafe!

  # Do not compress assets
  #config.assets.compress = false
  config.assets.compress = false
  
  #GRAPH_AUTOUPDATE = 1.0
  GRAPHVIZ_BINPATH = '/usr/local/bin/'
  QUEUE_SERVERS = ['localhost:11300']

  MONITOR_MIN_UPDATE_PERIOD = 2
  DASHBOARD_SYSTEM_RATE = MONITOR_MIN_UPDATE_PERIOD + 1
  DASHBOARD_WORKERS_RATE = 1
  DASHBOARD_BEANSTALK_RATE = 1
  DASHBOARD_JOBS_RATE = 2
  DASHBOARD_JOBS_LIMIT = 5
  
  WORKERD_POLL_DELAY = 1
  WORKERD_ZOMBIE_DELAY = 2 + WORKERD_POLL_DELAY

  RESTCLIENT_OPEN_TIMEOUT = 8
  RESTCLIENT_REQ_TIMEOUT = 30
  
  # Environnement-specific constants
  ENV_CONSTANTS = {
    :filer => '/Users/bruno/beta.pfmaf/',
    :transcoder => 'cpws.local',
    :catalog => 'cpws.local',
    :fai1 => 'vodka',
    :fai2 => 'vodka',
  }
  
end