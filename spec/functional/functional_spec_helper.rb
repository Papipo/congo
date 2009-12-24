require File.join(File.dirname(__FILE__), '..', 'spec_helper')

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, {
  :logger => Logger.new(TEST_DIR + '/test.log')
})
MongoMapper.database = 'congotest'

MongoMapper.database.collection_names.each do |collection|
  next if collection == 'system.indexes'
  MongoMapper.database.collection(collection).drop
end