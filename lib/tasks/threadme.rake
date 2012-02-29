desc "Test threading in ruby"
THREAD_COUNT = 4

task :threadme => :environment do
  puts "main: starting"
  t = Thread.new() {
    puts "thread: starting and sleeping for 2s"
    sleep 2
    puts "thread: ending"
  }

  puts "main: before join"
  t.join
  puts "main: after join"
end
