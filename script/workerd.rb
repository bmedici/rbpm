#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
require 'beanstalk-client'
USE_BEANSTALK = true


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
  worker = Worker.new(hostname, pid)
  
  Rails.logger.info "PID [#{pid}]: registered worker [#{worker.name}]"

  # Initialize own logger
  #logfile_worker = File.expand_path(File.join(Rails.root, 'log', 'workers', "worker_#{worker.id}.log"))
  logfile_worker = File.join(logs_dir, "rbpm_workers.log")
  wlog = ActiveSupport::BufferedLogger.new(logfile_worker)
  wlog.auto_flushing = true
  Rails.logger.info "PID [#{pid}]: logging to file [#{logfile_worker}]"
  
  # Connect worker to logger
  worker.use_logger(wlog)

  # What to do when asked to terminate
  Signal.trap("TERM") do
    Rails.logger.info "PID [#{pid}]: received term signal"
    Rails.logger.info "PID [#{pid}]: unregistering worker [#{worker.name}]"
    worker.shutdown
    exit
  end
  
  # Main endless loop
  begin
    
    if (USE_BEANSTALK==true)
      #beanstalk = Beanstalk::Pool.new(QUEUE_SERVERS)
      worker.handle_beanstalk_jobs
    else
      worker.poll_database
    end

  rescue Exceptions::WorkerFailedJobNotfound
    msg = "PID [#{pid}]: EXITING: worker failed to find the job: #{exception.message}"
    puts msg
    Rails.logger.info msg

  rescue Beanstalk::NotConnected
    msg = "PID [#{pid}]: EXITING: connexion to beanstalkd failed"
    puts msg
    Rails.logger.info msg

  rescue Exception => exception
    msg = "PID [#{pid}]: unhandled exception: #{exception.message}"
    puts msg
    Rails.logger.info msg

  end    

end