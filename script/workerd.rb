#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
require 'beanstalk-client'


# Global init
RBPM_APPDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
RBPM_LOGDIR = File.join(RBPM_APPDIR, 'log')
RBPM_HOSTNAME = `hostname`.chomp
RBPM_GLOBAL_LOGFILE  = File.join(RBPM_LOGDIR, 'rbpm_global.log')
RBPM_WORKERS_LOGFILE  = File.join(RBPM_LOGDIR, "rbpm_workers.log")
RBPM_DATABASE_LOGFILE = File.join(RBPM_LOGDIR, 'rbpm_db.log')
#logfile_worker = File.expand_path(File.join(Rails.root, 'log', 'workers', "worker_#{worker.id}.log"))

# Daemon options
daemon_options = {
  :multiple   => true,
  :dir_mode   => :normal,
  :dir        => File.join(RBPM_APPDIR, 'tmp', 'pids'),
  :backtrace  => true,
  :monitor    => true
  #:stop_proc  => :end_proc
}

def log(msg="", stdout = false)
  stamp = Time.now.strftime(WORKER_LOGFORMAT)
  msg = "#{stamp}\tPID [#{Process.pid}] #{msg}"

  # To STDOUT if really important
  puts msg if stdout
  
  # Log to Rails logger is initialized
  Rails.logger.info msg if defined? Rails
end


# Start daemon processes
Daemons.run_proc('rbpm_worker', daemon_options) do

  # Include Rails environment
  require File.expand_path(File.join(RBPM_APPDIR, 'config', 'environment'))

  # Initialize default logger
  pid = Process.pid
  Rails.logger = ActiveSupport::BufferedLogger.new(RBPM_GLOBAL_LOGFILE)
  Rails.logger.auto_flushing = true
  log "starting new worker process"

  # Initialize database logger
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(RBPM_DATABASE_LOGFILE)
  ActiveRecord::Base.logger.auto_flushing = true
  log "logging database to #{RBPM_DATABASE_LOGFILE}"

  # Initialize own logger
  wlog = ActiveSupport::BufferedLogger.new(RBPM_WORKERS_LOGFILE)
  wlog.auto_flushing = true
  log "logging workers  to #{RBPM_WORKERS_LOGFILE}"
  
  # Main block / endless loop
  loop do
    begin

      # Initialize worker, register it in our database, init logger
      worker = Worker.new(RBPM_HOSTNAME, pid)
      worker.use_logger(wlog)
      log "registered worker [#{worker.name}]"

      # # What to do when asked to terminate
      # Signal.trap("TERM") do
      #   log "unregistering worker [#{worker.name}]"
      #   worker.shutdown
      #   exit
      # end

      # Start handling jobs
      worker.handle_beanstalk_jobs

    rescue Exceptions::WorkerFailedJobNotfound => exception
      log "ATTENTION: worker could not find job: #{exception.message}"

    rescue Beanstalk::NotConnected => exception
      log "ATTENTION: connexion to beanstalkd failed"

    rescue Interrupt => exception
      log "ATTENTION: received Interrupt"

    rescue SystemExit => exception
      log "ATTENTION: received SystemExit, unregistering [#{worker.name}]"
      worker.shutdown
      exit

    rescue Exception => exception
      log "ATTENTION: unhandled exception [#{exception.class}] #{exception.message}"

    end    
    
    # If we're here, something wrong happened!
    sleep WORKER_REBOOT_DELAY

  end

end
