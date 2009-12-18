
require 'rubygems'
require 'uuidtools'

NUM_METRICS = 1000
NUM_DATAPOINTS = 21_600
NOW = Time.now.to_i

TIMES = (0..NUM_DATAPOINTS).map{ |t| NOW+t*120 }

ZEROS = TIMES.map{ |t| [t, 0.0 ] }
RANDOMS = TIMES.map{ |t| [t, rand] }

metric_zero   = Hash.new
metric_random = Hash.new

NUM_METRICS.times do |i|
  puts i
  id = UUID.random_create.to_s

  12.times do |mm|
    key = "#{id}/2008-#{mm+1}"

    metric_zero[key] = ZEROS
    metric_random[key] = RANDOMS

  end

end

puts "Total Metric Months: #{metric_zero.length}"
puts "Total DataPoints: #{metric_zero.length * metric_zero.values.first.length}"

puts "Writing zero.dump..."
File.open( 'zero.dump', 'w' ) do |out|
  Marshal.dump(metric_zero, out)
end

puts "Writing random.dump..."
File.open( 'random.dump', 'w' ) do |out|
  Marshal.dump(metric_random, out)
end



