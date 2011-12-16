require 'spec_helper'

describe Sec223fMultifamilyStatLimitSetValidations do
  
  before(:all) do
    class TestClass
      include Sec223fMultifamilyStatLimitSetValidations
      attr_accessor :zero_bedroom, :one_bedroom, :two_bedroom, :three_bedroom, :four_bedroom
      def initialize(attributes = {}) self.attributes = attributes; end
      def attributes=(attrs) attrs.each_pair {|k, v| send("#{k}=", v)}; end
    end
  end
  
  let(:attrs) {{:zero_bedroom=>0, :one_bedroom=>0, :two_bedroom=>0, :three_bedroom=>0, :four_bedroom=>0}}
  
  before(:each) {@stat_limit_set = TestClass.new attrs}

  specify {@stat_limit_set.should be_valid}
  
  context "invalid states" do
    
    after(:each) {@stat_limit_set.should_not be_valid}
    
    context "when bedrooms are positive non-integers" do
      specify {@stat_limit_set.zero_bedroom = 0.1}
      specify {@stat_limit_set.one_bedroom = 0.1}
      specify {@stat_limit_set.two_bedroom = 0.1}
      specify {@stat_limit_set.three_bedroom = 0.1}
      specify {@stat_limit_set.four_bedroom = 0.1}
    end
    
    context "when bedrooms are not present" do
      specify {@stat_limit_set.zero_bedroom = nil}
      specify {@stat_limit_set.one_bedroom = nil}
      specify {@stat_limit_set.two_bedroom = nil}
      specify {@stat_limit_set.three_bedroom = nil}
      specify {@stat_limit_set.four_bedroom = nil}
    end
    
    context "when bedrooms are negative" do
      specify {@stat_limit_set.zero_bedroom = -1}
      specify {@stat_limit_set.one_bedroom = -1}
      specify {@stat_limit_set.two_bedroom = -1}
      specify {@stat_limit_set.three_bedroom = -1}
      specify {@stat_limit_set.four_bedroom = -1}
    end
    
  end
end