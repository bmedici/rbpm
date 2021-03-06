Rbpm::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Specifies the header that your server uses for sending files
  # (comment out if your front-end server doesn't support this)
  #config.action_dispatch.x_sendfile_header = "X-Sendfile" # Use 'X-Accel-Redirect' for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #GRAPH_AUTOUPDATE = 1.0
  GRAPHVIZ_BINPATH = '/usr/bin/'
  QUEUE_SERVERS = ['vodka:11300']
  MONITOR_MIN_UPDATE_PERIOD = 2
  DASHBOARD_SYSTEM_RATE = MONITOR_MIN_UPDATE_PERIOD + 1
  DASHBOARD_WORKERS_RATE = 1
  DASHBOARD_BEANSTALK_RATE = 1
  DASHBOARD_JOBS_RATE = 2
  DASHBOARD_JOBS_LIMIT = 20

  WORKERD_POLL_DELAY = 1
  WORKERD_ZOMBIE_DELAY = 2 + WORKERD_POLL_DELAY

  RESTCLIENT_OPEN_TIMEOUT = 5
  RESTCLIENT_REQ_TIMEOUT = 300
  
  
  # Environnement-specific constants
  ENV_CONSTANTS = {
    :filer => '/home/pfmaf',
    :transcoder => 'vod38',
    :catalog => 'vod38',
    :fai1 => 'vodka',
    :fai2 => 'vodka',
  }

end