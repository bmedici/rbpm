require 'rubygems'        # if you use RubyGems
require 'daemons'

Daemons.run_proc('rbpm: worker_process') do
  loop do
    # Try to fetch a runnable job
    runnable = 
    puts "i'm running"
      sleep(1)
    end
end