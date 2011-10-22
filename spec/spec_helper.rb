$:.unshift( File.dirname(__FILE__) + '../../lib' )

require 'strings'
require 'rspec'

RSpec.configure do |config|
  config.mock_with(:mocha)
end
