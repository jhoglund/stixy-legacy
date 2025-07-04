IO.popen('ps h -C mongrel_rails -o pid,rss,args').readlines.each do |line|
  res = line.chomp.scan(/\d+/)
  port = line.chomp.scan(/(?!>-p )\d{4}(?= -P)/)[0]
  if res[0].to_i < 1 || res[1].to_i > 300000
    puts "Killing #{res[0]}... that was using #{res[1]}\n";
    IO.popen "kill -9 #{res[0]}"
    IO.popen "rm -f /home/stixy/logs/mongrel/mongrel.#{port}.pid"
    IO.popen "mongrel_rails start -d -e production -a 127.0.0.1 -c /home/stixy/stixy/current -p #{port} -P /home/stixy/logs/mongrel/mongrel.#{port}.pid -l /home/stixy/logs/mongrel/mongrel_production.#{port}.log"
    puts "Restarted mongrel_rails on port #{port}\n";
    File.open('/home/stixy/logs/mongrel/restart.log','a') do |file|
      file.write("Restarted mongrel_rails on port #{port} on #{Time.now.strftime("%B %d, %Y %I:%M %p")}\n")
    end
  end
end