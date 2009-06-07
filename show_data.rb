#!/usr/bin/env ruby

require 'serialport'

s = SerialPort.new(ARGV.shift, 9600)

loop do
  s.puts "FETCH";
  temp = s.gets[/[0-9A-F]+/].hex
  hum = s.gets[/[0-9A-F]+/].hex
  temp_c = temp * 0.01 - 40
  rh_lin = -0.0000028 * hum * hum + 0.0405 * hum - 4
  rh_true = ((temp_c - 25.0) * (0.01 + 0.00008 * hum)) + rh_lin
  puts "%.02f C, %.02f" % [temp_c, rh_true]
  sleep 1
end
