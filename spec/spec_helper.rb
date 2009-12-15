$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongo_mapper'

require 'congo'
require 'models'
require 'spec'
require 'spec/autorun'

test_dir = File.expand_path(File.dirname(__FILE__) + '/../tmp')
FileUtils.mkdir_p(test_dir) unless File.exist?(test_dir)

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, {
  :logger => Logger.new(test_dir + '/test.log')
})
MongoMapper.database = 'congotest'

MongoMapper.database.collection_names.each do |collection|
  next if collection == 'system.indexes'
  MongoMapper.database.collection(collection).drop
end


Spec::Runner.configure do |config|
  
end
