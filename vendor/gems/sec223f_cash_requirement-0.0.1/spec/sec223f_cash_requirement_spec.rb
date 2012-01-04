require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Sec223fCashRequirement" do
  it "has a version" do
    Sec223fCashRequirement::VERSION.should == "0.0.1"
  end
end