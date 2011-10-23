ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
$:.unshift( "#{ ROOT }/../../lib" )

require 'strings'
require 'rspec'

RSpec.configure do |config|
  config.mock_with(:mocha)

  def data_path(name)
    File.join(ROOT, 'spec', 'data', name)
  end
end
