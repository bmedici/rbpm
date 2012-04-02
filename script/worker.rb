#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
WAIT_DELAY = 1
ALLOW_MULTIPLE = true
ALLOW_MONITOR = true


# Global init
app_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
logs_dir = File.join(app_dir, 'log', 'workers')
hostname = `hostname`.chomp


# Daemon options
daemon_options = {
  :multiple   => ALLOW_MULTIPLE,
  :dir_mode   => :normal,
  :dir        => File.join(app_dir, 'tmp', 'pids'),
  :backtrace  => true,
  :monitor  => ALLOW_MONITOR
  #:stop_proc  => :end_proc
}


# Start daemon processes
Daemons.run_proc('rbpm_worker', daemon_options) do


  # Include Rails environment
  require File.expand_path(File.join(app_dir, 'config', 'environment'))


  # Initialize default logger
  pid = Process.pid
  logfile_rails = File.join(logs_dir, 'rails.log')
  Rails.logger = ActiveSupport::BufferedLogger.new(logfile_rails)
  Rails.logger.info "PID [#{pid}]: starting new worker process"


  # Initialize database logger
  logfile_db = File.join(logs_dir, 'database.log')
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(logfile_db)


  # Register worker (in the main loop to be sure we are created again if deleted meanwhile - DISABLED)
  worker = Worker.find_or_create_by_hostname_and_pid(hostname, pid)
  Rails.logger.info "PID [#{pid}]: registered host [#{hostname}] and pid [#{pid}] as worker [w#{worker.id}]"


  # What to do when asked to terminate
  Signal.trap("TERM") do
    Rails.logger.info "PID [#{pid}]: received term signal"
    Rails.logger.info "PID [#{pid}]: unregistering worker [w#{worker.id}]"
    worker.destroy
    exit
  end


  # Initialize own logger
  #logfile_worker = File.expand_path(File.join(Rails.root, 'log', 'workers', "worker_#{worker.id}.log"))
  logfile_worker = File.expand_path(File.join(Rails.root, 'log', 'workers', "workers.log"))
  wlog = ActiveSupport::BufferedLogger.new(logfile_worker)
  wlog.auto_flushing = true
  Rails.logger.info "PID [#{pid}]: logging to file [#{logfile_worker}]"


  # Main endless loop
  worker.log_to(wlog, "[w#{worker.id}]")
  worker.work

end