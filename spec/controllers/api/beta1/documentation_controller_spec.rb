require 'spec_helper'

describe Api::Beta1::DocumentationController, "#sec223f_refinance" do
  it "should have expected route", :type=>:routing do
    assert_routing({:path=>"api/beta1/documentation/sec223f_refinance", :method =>:get}, 
                   {:controller=>"api/beta1/documentation", :action =>"sec223f_refinance"})
  end
  
  describe "success" do
    it "should be a success" do
      get :sec223f_refinance
      response.should be_success
    end
  end
end

describe Api::Beta1::DocumentationController, "#sec223f_acquisition" do
  it "should have expected route", :type=>:routing do
    assert_routing({:path=>"api/beta1/documentation/sec223f_acquisition", :method =>:get}, 
                   {:controller=>"api/beta1/documentation", :action =>"sec223f_acquisition"})
  end
  
  describe "success" do
    it "should be a success" do
      get :sec223f_acquisition
      response.should be_success
    end
  end
end