
require 'rubygems'

require 'tokyocabinet'
DB = TokyoCabinet::BDB.new

class Array
  def pick
    self[rand(self.size)]
  end
end

# connect to the server
if !DB.open('./huge.tcb', TokyoCabinet::BDB::OREADER)
  ecode = DB.ecode
  STDERR.printf("open error: %s\n", DB.errmsg(ecode))
end

keys = DB.fwmkeys('')

puts "Found #{keys.size} keys."

require 'rbench'

RBench.run(10_000) do

  report "Fetching" do
    DB.get(keys.pick)
  end

end
