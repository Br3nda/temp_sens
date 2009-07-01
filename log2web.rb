#!/usr/bin/env ruby

STDIN.each_line do |line|
  epoch, temp, humidity = line.chomp.split
  
  temp_c = "%0.2f" % (temp.to_f - 273.15)
  temp_f = "%0.2f" % ((temp_c.to_f * 9 / 5) + 32)
  
  time = Time.at(epoch.to_i)
  
  begin
  File.open('/home/tim/public_html/isl7habitable.html', 'w') do |file|
    file.write <<-END
      <html>
        <head>
          <meta http-equiv="refresh" content="30" />
          <title>Is L7 Habitable?</title>
        </head>
        <body>
          <h1>Current temperature is #{temp}K (#{temp_c}&deg;C / #{temp_f}&deg;F)</h1>
          <object data="temperature.svg" type="image/svg+xml" style="width: 50%; padding-left: 25%;"></object>
          <h1>Relative humidity is #{humidity}%</h1>
          <object data="humidity.svg" type="image/svg+xml" style="width: 50%; padding-left: 25%;"></object>
          <p>Last updated: #{time.strftime('%Y-%m-%d %H:%M:%S')}</p>
          
        </body>
      </html>
    END
  end
  system "tail -n 17280 humtempsens.log > section.log"
  system "gnuplot all_time.plot"
  system "cp *.svg ~/public_html/"
  system "rsync -vtz /home/tim/public_html/isl7habitable.html *.svg goddard.net.nz:public_html/"
  rescue Exception => e
  end
end
