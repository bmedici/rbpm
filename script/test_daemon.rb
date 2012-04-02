#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

# Global init
dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

daemon_options = {
  :multiple   => false,
  :dir_mode   => :normal,
  :dir        => File.join(dir, 'tmp', 'pids'),
  :backtrace  => true
}
daemon_options = {}

require File.expand_path('../../config/environment',  __FILE__)

Daemons.run_proc('test_server', daemon_options) do

  Rails.logger = ActiveSupport::BufferedLogger.new('/tmp/log.out', :auto_flushing => true)
  ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new('/tmp/db.out')

  # if ARGV.include?('--')
  #   ARGV.slice! 0..ARGV.index('--')
  # else
  #   ARGV.clear
  # end
  
  # Initialize a local logger
  
  loop do
    steps = Step.all
    puts "ok"
    sleep(1)
  end
end


