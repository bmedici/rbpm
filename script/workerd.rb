#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
require 'beanstalk-client'
USE_BEANSTALK = true

# Global init
RBPM_APPDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
RBPM_LOGDIR = File.join(RBPM_APPDIR, 'log')
hostname = `hostname`.chomp

#logfile_worker = File.expand_path(File.join(Rails.root, 'log', 'workers', "worker_#{worker.id}.log"))
RBPM_GLOBAL_LOGFILE  = File.join(RBPM_LOGDIR, 'rbpm_global.log')
RBPM_WORKERS_LOGFILE  = File.join(RBPM_LOGDIR, "rbpm_workers.log")
RBPM_DATABASE_LOGFILE = File.join(RBPM_LOGDIR, 'rbpm_db.log')
#RBPM_DATABASE_LOGFILE = RBPM_WORKERS_LOGFILE


# Daemon options
daemon_options = {
  :multiple   => true,
  :dir_mode   => :normal,
  :dir        => File.join(RBPM_APPDIR, 'tmp', 'pids'),
  :backtrace  => true,
  :monitor    => true
  #:stop_proc  => :end_proc
}


# Start daemon processes
Daemons.run_proc('rbpm_worker', daemon_options) do

  # Include Rails environment
  require File.expand_path(File.join(RBPM_APPDIR, 'config', 'environment'))

  # Initialize default logger
  pid = Process.pid
  Rails.logger = ActiveSupport::BufferedLogger.new(RBPM_GLOBAL_LOGFILE)
  Rails.logger.auto_flushing = true
  Rails.logger.info "PID [#{pid}]: starting new worker process"

  # Initialize database logger
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(RBPM_DATABASE_LOGFILE)
  ActiveRecord::Base.logger.auto_flushing = true
  Rails.logger.info "PID [#{pid}]: logging database to file [#{RBPM_DATABASE_LOGFILE}]"

  # Initialize own logger
  wlog = ActiveSupport::BufferedLogger.new(RBPM_WORKERS_LOGFILE)
  wlog.auto_flushing = true
  Rails.logger.info "PID [#{pid}]: logging  workers to file [#{RBPM_WORKERS_LOGFILE}]"

  # Initialize worker, register it in our database, init logger
  worker = Worker.new(hostname, pid)
  worker.use_logger(wlog)
  Rails.logger.info "PID [#{pid}]: registered worker [#{worker.name}]"

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

  rescue Exceptions::WorkerFailedJobNotfound => exception
    msg = "PID [#{pid}]: WORKERD EXITING: worker failed to find the job: #{exception.message}"
    puts msg
    Rails.logger.info msg

  rescue Beanstalk::NotConnected => exception
    msg = "PID [#{pid}]: WORKERD EXITING: connexion to beanstalkd failed"
    puts msg
    Rails.logger.info msg

  rescue Interrupt => exception
    msg = "PID [#{pid}]: WORKERD EXITING: received Interrupt"
    puts msg
    Rails.logger.info msg

  rescue Exception => exception
    msg = "PID [#{pid}]: WORKERD unhandled exception [#{exception.class}] #{exception.message}"
    puts msg
    Rails.logger.info msg

  end    

end