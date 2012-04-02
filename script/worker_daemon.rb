#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
WAIT_DELAY = 1


# Global init
app_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
logs_dir = File.join(app_dir, 'log', 'workers')
hostname = `hostname`.chomp

# Daemon options
daemon_options = {
  :multiple   => true,
  :dir_mode   => :normal,
  :dir        => File.join(app_dir, 'tmp', 'pids'),
  :backtrace  => true,
  :monitor  => true,
  :stop_proc  => :end_proc
}
#daemon_options = {}

# Include Rails environment
require File.expand_path('../../config/environment',  __FILE__)

# Start daemon processes
Daemons.run_proc('rbpm_worker', daemon_options) do
  
  
  # Daemons.at_exit do
  #   # execute your extra code here
  # end
  
  # Initialize Rails default logger
  pid = Process.pid
  logfile_rails = File.join(logs_dir, 'rails.log')
  Rails.logger = ActiveSupport::BufferedLogger.new(logfile_rails)
  Rails.logger.info "PID [#{pid}]: starting new worker process"

  # Instanciate database logger
  logfile_db = File.join(logs_dir, 'database.log')
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(logfile_db)

  # Register worker (in the main loop to be sure we are created again if deleted meanwhile - DISABLED)
  worker = Worker.find_or_create_by_hostname_and_pid(hostname, pid)
  Rails.logger.info "PID [#{pid}]: registered host [#{hostname}] and pid [#{pid}] as worker [w#{worker.id}]"

  # Initialize this worker's own logger
  logfile_worker = File.join(logs_dir, "worker_#{worker.id}.log")
  wlog = ActiveSupport::BufferedLogger.new(logfile_worker)
  wlog.auto_flushing = true
  Rails.logger.info "PID [#{pid}]: logging to file [#{logfile_worker}]"

  trap("TERM") do
    Rails.logger.info "PID [#{pid}]: received term signal, unregistering worker [w#{worker.id}]"
    worker.destroy
    exit
  end
  
  # Main endless loop
  worker.start

end
