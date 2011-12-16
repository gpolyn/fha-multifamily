# Author:: Gallagher Polyn  (mailto:gallagher.polyn@gmail.com)
# Copyright:: Copyright (c) 2011 Gallagher Polyn

require 'test_helper'

class Sec223fRefinanceControllerTest < ActionController::TestCase
  
  test "should generate path and recognize route for GET loan" do
    assert_routing({:path => "/sec_223f_refinance", :method => :get},{:action => "loan", :controller=>"sec223f_refinance"})
  end
  
end