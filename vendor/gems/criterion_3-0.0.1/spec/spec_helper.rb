$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'criterion_3'
require 'rspec'
require 'rspec/autorun' # may relate to autotest...

RSpec.configure do |config|
  
end