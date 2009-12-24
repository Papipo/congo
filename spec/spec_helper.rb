$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'mocha'
require 'mongo_mapper'

require 'congo'
require 'models'
require 'spec'
require 'spec/autorun'

TEST_DIR = File.expand_path(File.dirname(__FILE__) + '/../tmp')

FileUtils.mkdir_p(test_dir) unless File.exist?(TEST_DIR)

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
