require 'numerousapp'
require 'mongo'

myApiKey='thisistheapikeyitismykey'
myMetricKey='1234567890123456789'

myMongoURL="mongodb://user:pass@c999.lamppost.9.mongolayer.com:10999,lamppost.8.mongolayer.com:10888/dbname?replicaSet=set-e3f11b0d925f97f264d6230745"

numerous=Numerous.new(myApiKey)
metric=numerous.metric(myMetricKey)

def every_n_seconds(n)  
  loop do
    before = Time.now
    yield
    interval = n-(Time.now-before)
    sleep(interval) if interval > 0
  end
end

Mongo::Logger.logger.level = 1

client=Mongo::Client.new(myMongoURL)  
every_n_seconds(10) do
  statdoc=client.command(:collstats => 'names').documents[0]
    begin
    metric.write(statdoc['count'],onlyIf:true)
  rescue NumerousMetricConflictError
  end
end

