Process.exit if ARGV.size < 1

logs = Hash.new
temp_dir = ARGV[0]
delta = ARGV[1].to_f != 0 ? ARGV[1] : 1

ARGV[1..-1].each do |arg|
  next if ARGV[1].to_f != 0
  pids = `pidof "#{arg}"`

  pids.split.each do |pid|
    logs[pid] = File.open("#{temp_dir}/#{arg}.#{pid}.csv", "w")
  end
end

while true do
  logs.each do |pid, log|
    begin
      f = File.open("/proc/#{pid}/status", 'r').read
    rescue
      next
    end
    
    vmpeak = f.match('VmPeak:\s+(\d+)\s+kB')[1]
    vmsize = f.match('VmSize:\s+(\d+)\s+kB')[1]
    vmrss = f.match('VmRSS:\s+(\d+)\s+kB')[1]

    log.write("#{vmpeak},#{vmsize},#{vmrss}\n")
    log.flush
  end
  
  sleep delta.to_i
end
