logs = Hash.new
temp_dir = ARGV[0]
delta = ARGV[1].to_f != 0 ? ARGV[1] : 1

while true do
  ARGV[1..-1].each do |arg|
    next if ARGV[1].to_f != 0
    (`pidof #{arg}`.split-logs.keys).each do |pid|
      logs[pid] = File.open("#{temp_dir}/#{(arg.gsub(/[^a-zA-Z 0-9]/, "")).gsub(/\s/,'-')}.#{pid}.csv", "w")
    end
  end

  logs.each do |pid, log|
    begin
      f = File.open("/proc/#{pid}/status", 'r').read
    rescue
      next
    end
    
    begin
      vmpeak = f.match('VmPeak:\s+(\d+)\s+kB')[1]
      vmsize = f.match('VmSize:\s+(\d+)\s+kB')[1]
      vmrss = f.match('VmRSS:\s+(\d+)\s+kB')[1]

      log.write("#{vmpeak},#{vmsize},#{vmrss}\n")
      log.flush
    rescue
      log.close
      logs.delete(pid)
    end
  end
  
  sleep delta.to_i
end
