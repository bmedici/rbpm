#!/usr/bin/env ruby
require 'socket'               # Get sockets from stdlib
PORT= 5000

puts "Listenning on port #{PORT}"

server = TCPServer.open(PORT)  # Socket to listen on port 2000
loop {                         # Servers run forever
  # Accept conection
  client = server.accept       # Wait for a client to connect
  puts "client connected"
  
  # Get some data
  received = []
  while line = client.gets
    line.trim!
    break if line.empty?
    received << line
  end
  
  # Ack the message
  puts "#################### RECEIVED ####################"
  received.each do |line|
    puts "# #{line}"
  end
  puts "##################################################"
  
  # Send a reply
  3.times do
    client.puts("it's now #{Time.now.ctime}")
    sleep 1
  end

  client.puts "bye bye !"
  client.close                 # Disconnect from the client
  puts "client disconnected, received [#{received.size}] lines"
  }