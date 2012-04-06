#!/usr/bin/env ruby

config = {
  11 => [33, 35, 37, 39],
  12 => [41, 43, 45, 47],
  13 => [34, 36, 38, 40],
  14 => [42, 44, 46, 48],
  
  8 => [17, 19, 21, 23, 25, 27, 29, 31],
  9 => [18, 20, 22, 24, 26, 28, 30, 32],
  
  21 => [15, 16],
  22 => [13, 14],
  23 => [11, 12],
  24 => [9, 10],
}

config = {
  21 => [7, 8, 9, 10],
  22 => [11, 12],
  23 => [13, 14],
  24 => [15, 16],
}


def snippet(vlan, port)
puts "interface FastEthernet1/0/#{port}"
puts "switchport mode access"
puts "switchport access vlan #{vlan}"
puts "exit"
end


config.each do |vlan, ports|
  ports.each do |port|
    snippet(vlan, port)
  end
end


