regex = /memory_usages:(?:.- (\d+))*/m
memusage = File.open(ARGV[0], 'r').read
iterations = ARGV[1].to_i || 5

mem_values = memusage.scan(regex).flatten.map(&:to_i)

global_values = Array.new
mem_values.each_slice(iterations) { |slice|  global_values << (slice.inject{ |sum, n| sum + n} / iterations) }

mean = global_values.inject{ |sum, n| sum + n } / global_values.size

puts "mean: #{mean}"

