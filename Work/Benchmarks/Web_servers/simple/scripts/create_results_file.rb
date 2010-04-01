tests = ["50_1", "100_10","500_50","500_100","2500_500"]
pages = ["portal", "homepage", "publication"]
webservers = ["cherokee_thin","apache2_thin","nginx_thin","nginx_unicorn","cherokee_thin_threaded","apache2_thin_threaded","nginx_thin_threaded","apache2_passenger","nginx_passenger"]
# All: ["cherokee_thin","apache2_thin","nginx_thin","cherokee_thin_threaded","apache2_thin_threaded","nginx_thin_threaded","apache2_passenger","nginx_passenger"]
# Proxy benchmarks: ["cherokee_thin","apache2_thin","nginx_thin"]
# Thin VS Thin threaded: ["nginx_thin", "nginx_thin_threaded"]


output = File.open("results.csv", "w")

tests.each do |test|
  pages.each do |page|
    webservers.each do |webserver|
      folder = "results/#{webserver}/#{page}/#{test}/"
      begin
        file = File.open(folder+"ab.bench")
      rescue
        next
      end
      
      # Process ab file      
      f = file.read
      regex = ['Requests\sper\ssecond:\s+(\S+)\s', 'Time\staken\sfor\stests:\s+(\S+)\s+seconds']
      #'Total:\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+', 'Total:\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)', 'Total:\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+'
      regex.each do |exp|
        begin
          throw unless f.match('Document\sLength:\s+(\S+)')[1].to_i > 200 and ((f.match('Failed\srequests:\s+(\S+)')[1].to_i-f.match('\sLength:\s+(\S+)')[1].to_i) < 1) and (f.match('2xx\sresponses:\s+(\S+)').nil? or f.match('2xx\sresponses:\s+(\S+)')[1].to_i < test.split("_")[0].to_i*0.05)
          output.write(f.match(exp)[1]+",")
        rescue
          output.write("FAIL,")
        end
      end
      
      ['/(\d+),.+\n/'].each do |regex|
        array = []
        average = 0
        
        Dir[folder+"**.csv"].each do |mem_file|
          f = File.open(mem_file).read
          
          array.concat(f.scan(regex).flatten)
        end
        
        array.each { |element| average += element.to_f/array.size }
        
        output.write(average.to_i.to_s+",")
      end
      output.write("\n")
      output.flush
    end
  end
end

