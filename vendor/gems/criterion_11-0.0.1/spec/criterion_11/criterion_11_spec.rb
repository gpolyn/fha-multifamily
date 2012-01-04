require File.dirname(__FILE__) + "/../spec_helper.rb"

class Criterion11CommonAttributesTestClass
  include Criterion11::CommonAttributes
end

describe Criterion11::CommonAttributes do
  
  let(:valid_instance) {Criterion11CommonAttributesTestClass.new}
  
  it_behaves_like "any implementation of Criterion11"
  
  describe "line_a" do
    it "should raise NotImplementedError" do
      lambda {valid_instance.line_a}.should raise_error(NotImplementedError)
    end
  end
  
end