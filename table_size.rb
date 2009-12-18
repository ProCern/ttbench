
require 'rubygems'
require 'uuidtools'
require 'tokyocabinet'
include TokyoCabinet

NUM_METRICS = 1_000
DATAPOINTS_PER_DAY = 720   
NOW = Time.now.to_i

metric_ids = (1..NUM_METRICS).map { |i| UUID.sha1_create(UUID_DNS_NAMESPACE, i.to_s) }
timestamps = (1..DATAPOINTS_PER_DAY).map { |i| NOW + i * (86400 / DATAPOINTS_PER_DAY) }

tdb = TDB.new
if !tdb.open("sizetest.tct", TDB::OWRITER | TDB::OCREAT | TDB::OTRUNC)
  ecode = tdb.ecode
  STDERR.printf("open error: %s\n", tdb.errmsg(ecode))
end

tdb.optimize( 4 * (1024 ** 2), 2048, 2048, TDB::TLARGE | TDB::TBZIP)

g_start = t_start = Time.now
metric_ids.each_with_index do |id, idx|
  if (idx + 1) % 100 == 0
    t_end = Time.now
    puts "Wrote #{idx+1} metrics in #{t_end - g_start}s (#{t_end - t_start}s)"
    t_start = Time.now
  end

  timestamps.each do |i|

    key = "#{id}/#{i}"

    data = { "timestamp" => i.to_s,
             "value" => rand.to_s,
             #"value" => "0.0",
             "id" => id.to_s }

    if !tdb.put(key, data)
      ecode = tdb.ecode
      STDERR.printf("get error: %s\n", tdb.errmsg(ecode))
    end

  end
end





