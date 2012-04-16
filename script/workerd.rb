#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'


# Global init
app_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
logs_dir = File.join(app_dir, 'log')
hostname = `hostname`.chomp


# Daemon options
daemon_options = {
  :multiple   => true,
  :dir_mode   => :normal,
  :dir        => File.join(app_dir, 'tmp', 'pids'),
  :backtrace  => true,
  :monitor    => true
  #:stop_proc  => :end_proc
}


# Start daemon processes
Daemons.run_proc('rbpm_worker', daemon_options) do

  # Include Rails environment
  require File.expand_path(File.join(app_dir, 'config', 'environment'))

  # Initialize default logger
  pid = Process.pid
  logfile_rails = File.join(logs_dir, 'rbpm_global.log')
  Rails.logger = ActiveSupport::BufferedLogger.new(logfile_rails)
  Rails.logger.info "PID [#{pid}]: starting new worker process"
  Rails.logger.auto_flushing = true

  # Initialize database logger
  logfile_db = File.join(logs_dir, 'rbpm_db.log')
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(logfile_db)

  # Register worker in our database
  worker = Worker.find_or_create_by_hostname_and_pid(hostname, pid)
  Rails.logger.info "PID [#{pid}]: registered host [#{hostname}] and pid [#{pid}] as worker [w#{worker.id}]"

  # Initialize own logger
  #logfile_worker = File.expand_path(File.join(Rails.root, 'log', 'workers', "worker_#{worker.id}.log"))
  logfile_worker = File.join(logs_dir, "rbpm_workers.log")
  wlog = ActiveSupport::BufferedLogger.new(logfile_worker)
  wlog.auto_flushing = true
  Rails.logger.info "PID [#{pid}]: logging to file [#{logfile_worker}]"

  # What to do when asked to terminate
  Signal.trap("TERM") do
    Rails.logger.info "PID [#{pid}]: received term signal"
    Rails.logger.info "PID [#{pid}]: unregistering worker [w#{worker.id}]"
    worker.destroy
    exit
  end

  # Main endless loop
  worker.log_to(wlog, "[w#{worker.id}]")
  worker.work

end