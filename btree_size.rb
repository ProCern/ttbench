
require 'rubygems'
require 'uuidtools'
require 'tokyocabinet'
include TokyoCabinet

NUM_METRICS = 1_000
DATAPOINTS_PER_DAY = 720   
NOW = Time.now.to_i

metric_ids = (1..NUM_METRICS).map { |i| UUID.sha1_create(UUID_DNS_NAMESPACE, i.to_s) }
timestamps = (1..DATAPOINTS_PER_DAY).map { |i| NOW + i * (86400 / DATAPOINTS_PER_DAY) }

bdb = BDB.new
if !bdb.open("stringrandtest.tcb", BDB::OWRITER | BDB::OCREAT | BDB::OTRUNC)
  ecode = bdb.ecode
  STDERR.printf("open error: %s\n", bdb.errmsg(ecode))
end

bdb.optimize( 2048, 4096, 4 * (1024 ** 2), nil, nil, BDB::TLARGE | BDB::TBZIP)

g_start = t_start = Time.now
metric_ids.each_with_index do |id, idx|
  if (idx + 1) % 100 == 0
    t_end = Time.now
    puts "Wrote #{idx+1} metrics in #{t_end - g_start}s (#{t_end - t_start}s)"
    t_start = Time.now
  end

  key = "#{id}/100"

  data = timestamps.map { |t| 
    val = rand.to_s
    [t, val.length, val].pack('IIa*') 
  }.join

  if !bdb.put(key, data)
    ecode = bdb.ecode
    STDERR.printf("get error: %s\n", bdb.errmsg(ecode))
  end

end





