array = Array.new
data = ''
f = File.open("table.txt", "r") 
f.each_line do |line|
  array[f.lineno-1] = line.gsub(' ', '').split("&")
end

# Multirow
(0..2).each do |num|
  counter = 0
  index = 0
  string = "fail"
  
  array.each_index do |ind|
    temp = array[ind][num].match(/\{([^}]+)\}$/)
  
    if counter != 0 and (not temp.nil? or array[ind] == array.last)
      counter += 1 if array[ind] == array.last
      
      array[index][num] = '\multirow'+"{#{counter}}{*}{#{string}}"
      (index+1..index+counter-1).each { |i| array[i][num] = "" }
      
      index = ind
      counter = 1
      string = temp[1] unless temp.nil?
      
    elsif not temp.nil?
      index = ind
      counter = 1
      string = temp[1]
    else
      counter += 1
    end
  end
end

# Bold
slice = 9
array.each_slice(slice) do |lines|
  arr = (0..slice-1).inject([]) { |all, cur| all << (lines[cur][4] == "FAIL" ? 0 : lines[cur][4].to_f) }
  max = arr.max unless arr.nil?
  (0..slice-1).each do |cur|
    lines[cur][4] = '\textbf{'+lines[cur][4]+'}' if lines[cur][4].to_f == max and lines[cur][4] != "FAIL"
  end
  
  arr = (0..slice-1).inject([]) { |all, cur| all << (lines[cur][5] == "FAIL" ? 999999999999 : lines[cur][5].to_f) }
  min = arr.min unless arr.nil?
  (0..slice-1).each do |cur|
    lines[cur][5] = '\textbf{'+lines[cur][5]+'}' if lines[cur][5].to_f == min and lines[cur][5] != "FAIL"
  end
  
  arr = (0..slice-1).inject([]) { |all, cur| all << lines[cur][6].split('\\')[0].to_i }
  min = arr.min unless arr.nil?
  (0..slice-1).each do |cur|
    lines[cur][6] = '\textbf{'+lines[cur][6].split('\\')[0]+'}'+'\\\\\\'+lines[cur][6].split('\\')[3] if lines[cur][6].split('\\')[0].to_i == min
  end
end

array.each do |line|
  line.each do |element|
    print element + (element == line.last ? "" : " & ")
  end
end


#array.each_index { |l| 
#  array[l].each_index { |c| 
#    puts "#{l},#{c}: #{array[l][c]}"
#  }
#}
