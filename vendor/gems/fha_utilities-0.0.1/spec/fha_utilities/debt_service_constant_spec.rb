require File.dirname(__FILE__) + "/../spec_helper.rb"

describe FhaUtilities::DebtServiceConstant do
  
  it "should return the expected percent result" do
    attributes = {:mortgage_interest_rate=>5.85, :term_in_months=>420}
    expected = 6.72182588016
    tolerance = 0.000000000005
    FhaUtilities::DebtServiceConstant.instance.get_percent(attributes).should be_within(tolerance).of expected
  end
  
  it "should return the expected decimal result" do
    attributes = {:mortgage_interest_rate=>5.85, :term_in_months=>420}
    expected = 0.0672182588016
    tolerance = 0.00000000000005
    FhaUtilities::DebtServiceConstant.instance.get_decimal(attributes).should be_within(tolerance).of expected
  end
  
end