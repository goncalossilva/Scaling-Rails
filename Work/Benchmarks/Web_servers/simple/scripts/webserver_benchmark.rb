# !/usr/bin/ruby
# usage: ruby webserver_benchmark.rb http://192.168.10.99/ cherokee_thin ruby18 cherokee-worker

require "fileutils"

Process.exit if ARGV.size < 6

# variables
start = ARGV[0]
stop = ARGV[1]
url = ARGV[2][-1,1] == "/" ? ARGV[2] : ARGV[2]+"/"
webserver = ARGV[3]
delta = ARGV[4].to_f != 0 ? ARGV[4] : 0.5
processes = ARGV[4..-1]
test_urls = {"homepage" => url, "portal" => "#{url}public/schools/eb1ji-de-aldeia-nova/pages/95", "publication" => "#{url}public/publications/492"}
ab_tests = [[50,1],[100, 10],[500,50],[500,100],[2500,500]]

# create destination directories
print "Creating working directories... "
test_urls.each do |page,url|
  ab_tests.each do |ab_test|
    FileUtils.mkdir_p "results/#{webserver}/#{page}/#{ab_test[0]}_#{ab_test[1]}"
  end
end
puts "DONE"

# run the benchmark
test_urls.each do |page,url|
  # run tests
  ab_tests.each do |ab_test|
    # start server
    system start
    sleep 3
    system "ab -n 10 -c 1 #{url} > /dev/null" # warmup
    sleep 20
  
    system "ruby19 monitor.rb results/#{webserver}/#{page}/#{ab_test[0]}_#{ab_test[1]} #{processes.join(" ")} &" # memory logging
    
    print "Running benchmark on #{page} with #{ab_test[0]} requests (#{ab_test[1]} concurrent)... "
    
    system "ab -n #{ab_test[0]} -c #{ab_test[1]} #{url} > results/#{webserver}/#{page}/#{ab_test[0]}_#{ab_test[1]}/ab.bench" # run benchmark
    
    system "killall -9 ruby19" # kill memory logger
     
    puts "DONE"
    
    # stop
    system stop
    sleep 30
  end
  

end  

puts "Exiting... DONE"

