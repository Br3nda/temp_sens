#!/usr/bin/env ruby

require 'serialport'

s = SerialPort.new(ARGV.shift, 9600)

last_temp = nil

loop do
  s.puts "FETCH";
  temp = s.gets[/[0-9A-F]+/].hex
  hum = s.gets[/[0-9A-F]+/].hex
  temp_k = temp * 0.01 - 40 + 273.15
  rh_lin = -0.0000028 * hum * hum + 0.0405 * hum - 4
  rh_true = ((temp_k - 25.0) * (0.01 + 0.00008 * hum)) + rh_lin
  puts "%.02f C, %.02f (moving avg %0.2f)" % [temp_k, rh_true, last_temp || temp_k]
  File.open('humtempsens.log', 'a') {|file| file.write "%d %.02f %.02f\n" % [Time.now.to_i, temp_k, rh_true]}
  if last_temp
    if temp_k > last_temp
      s.puts "OUT C ef"
    elsif temp_k < last_temp
      s.puts "OUT C df"
    else
      s.puts "OUT C ff"
    end
    last_temp = (last_temp / 2.0) + (temp_k / 2.0)
  else
    s.puts "OUT C ff"
    last_temp = temp_k
  end
  sleep 10
end
