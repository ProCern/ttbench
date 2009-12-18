
require 'rubygems'
require 'uuidtools'

class Array
  def to_hash
    h = {}
    each { |k,v| h[k] = v }
    h
  end
end

num_metrics = Integer(ARGV[0]) || 1000
doc_size    = Integer(ARGV[1]) || 1024

puts "Generating #{num_metrics} UUIDs"
metric_ids = (1..num_metrics).map { |i| i.to_s }

doc = " " * doc_size

require 'tokyocabinet'
DB = TokyoCabinet::BDB.new

# connect to the server
if !DB.open('./huge.hcb', TokyoCabinet::BDB::OWRITER | TokyoCabinet::BDB::OCREAT | TokyoCabinet::BDB::OTRUNC)
  ecode = DB.ecode
  STDERR.printf("open error: %s\n", DB.errmsg(ecode))
end

DB.optimize(1024, 2048, (1024 ** 2) * 4, nil, nil, TokyoCabinet::BDB::TLARGE | TokyoCabinet::BDB::TBZIP)
puts "Writing..."
i = 0
g_start = t_start = Time.now
metric_ids.each do |id| 
  i += 1
  if i % 1000 == 0
    t_end = Time.now
    puts "Wrote #{i} metrics in #{t_end - g_start}s (#{t_end - t_start}s)"
    t_start = Time.now
  end

  (1..366).each do |ddd|
    key = "#{id}/#{ddd}"
    DB.put(key, doc) 
  end
end

