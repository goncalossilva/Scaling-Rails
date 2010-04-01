#!/usr/bin/ruby

path = "autobench_results_ruby18/"+ARGV[0]
results = Hash.new

# get all values from all files
Dir[path+"/*.csv"].each do |file|
  f = File.open(file).read
  name = File.basename(file).gsub(/\.[a-zA-Z0-9]+$/, "")
  
  f.scan(/^([\d\.]+),([\d\.]+),(?:[\d\.]+,){2}([\d\.]+),(?:[\d\.]+,){4}([\d\.]+)/).each do |value|
    value[2] = 0 if value[3].to_f > 0
    
    results[name].nil? ? results[name] = { value[0] => [value[1], value[2]] } : results[name].merge!({ value[0] => [value[1], value[2]]})
  end
end

results.each { |key, value| results[key] = value.to_a }
results = results.to_a

r = File.open("results_autobench_requests_#{ARGV[0]}.csv", "w")
r.write "time,"
results.first[1].each do |result|
  r.write result[0]+","
end
r.write "\n"
results.each do |webserver, results|
  r.write webserver+","
  results.each do |time, values|
    r.write values[0].to_s+","
  end
  r.write "\n"
end

w = File.open("results_autobench_replies_#{ARGV[0]}.csv", "w")
w.write "time,"
results.first[1].each do |result|
  w.write result[0]+","
end
w.write "\n"
results.each do |webserver, results|
  w.write webserver+","
  results.each do |time, values|
    w.write values[1].to_s+","
  end
  w.write "\n"
end

output = File.open("results_autobench_memory_#{ARGV[0]}.csv", "w")
Dir[path+"/**/"][1..-1].each do |webserver_path|
  name = webserver_path.split("/").last
  output.write(name+",")
  
  ['/.+,(\d+)\n/'].each do |regex|
    array = []
    total = 0
    
    Dir[path+"/#{name}/**.csv"].each do |mem_file|
      f = File.open(mem_file).read
      
      array << f.scan(/.+,(\d+)\n/).flatten.max
      
      f.close
    end

    array.each { |element| total += element.to_f }
    
    output.write((total/1024).to_i.to_s+",")
  end
  
  output.write("\n")
  output.flush
end
