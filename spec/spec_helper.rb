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

FileUtils.mkdir_p(TEST_DIR) unless File.exist?(TEST_DIR)


I18n.load_path << Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.{rb,yml}') ] 
I18n.default_locale = :en

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
