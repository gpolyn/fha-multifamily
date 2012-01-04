require File.dirname(__FILE__) + "/../spec_helper.rb"

class Criterion11Sec223fAcquisitionTestClass
  include Criterion11::Sec223f::Acquisition
end

describe Criterion11::Sec223f::Acquisition do
  
  let(:valid_instance) do
    attrs = {:percent_multiplier => 85, :purchase_price_of_project => 12_300_000,
             :repairs_and_improvements => 75_000, :legal_and_organizational => 15_000,
             :initial_deposit_to_replacement_reserve => 30_000, :title_and_recording=>10_000,
             :financing_fee=>1.5, :financing_fee_is_percent_of_loan=>true,
             :value_in_fee_simple=> 14_000_000,
             :fha_inspection_fee => 3_000, :third_party_reports => 15_000,
             :survey => 5_000, :other => 10_000, :major_movable_equipment => 100_000,
             :replacement_reserves_on_deposit => 45_000, :permanent_placement_rate => 0.5,
             :first_year_mortgage_insurance_premium_rate => 1, :discounts_rate => 1,
             :mortgagable_bond_costs_rate => 0.75, :exam_fee_rate => 0.3}
    Criterion11Sec223fAcquisitionTestClass.new attrs
  end
  
  it_behaves_like "any implementation of Criterion11"
  it_behaves_like "any full implementation of Criterion11"
  
  specify {valid_instance.should be_a_kind_of Criterion7}
  
  describe "line_c" do
    context "public capital sources only" do
      it "should be 9_635_900" do
        valid_instance.mortgagable_bond_costs_rate = nil
        valid_instance.discounts_rate = nil
        valid_instance.grants = 1_000_000
        valid_instance.gifts = 1_000_000 
        valid_instance.public_loans = 500_000
        valid_instance.tax_credits = 500_000
        valid_instance.line_c.should be_within(0.005).of 6_635_900
      end
    end
  end
  
  describe "project_cost" do
    context "line_b7 is nil" do
      it "should be 100% the transaction costs less any RFR or major moveable on deposit" do
        valid_instance.project_cost.should be_within(0.005).of 12_973_100
      end
    end
    
    context "line_b7 is not nil" do
      it "should be < 100% the transaction costs less any RFR or major moveable on deposit" do
        valid_instance.should_receive(:line_b7).and_return 1_000_000
        valid_instance.project_cost.should be < 12_973_100
      end
    end
  end
  
  describe "line_a" do
    it "should be an alias for project_cost" do
      valid_instance.should_receive(:project_cost).and_return some_int = 12345
      valid_instance.line_a.should == some_int
    end
  end
  
  describe "value_in_fee_simple" do
    
    after do
      valid_instance.should_not be_valid
      valid_instance.errors[:value_in_fee_simple].should == [@expected_msg]
    end
    
    it "should be required" do
      valid_instance.value_in_fee_simple = nil
      @expected_msg = "is not a number"
    end
    
    it "should be greater than or equal to 0" do
      valid_instance.value_in_fee_simple = -1
      @expected_msg = "must be greater than or equal to 0"
    end
  end
  
  describe "private_loans" do
    
    before do
      valid_instance.value_in_fee_simple = 7_000_000
      valid_instance.private_loans = 3_000_000
    end
    
    it "should be in error if, when added to the mortgage amount, it exceeds 92.5% of value" do
      max = valid_instance.value_in_fee_simple * 0.925
      valid_instance.should_not be_valid
      expected_msg = "when added to the mortgage amount must not exceed 92.5%" + 
                     " of project value (#{max})"
      valid_instance.errors[:private_loans].should == [expected_msg]
    end
    
    context "when other errors already present" do
      it "should be have no errors" do
        valid_instance.other = -1
        valid_instance.should_not be_valid
        (valid_instance.errors[:private_loans].empty?).should be true
      end
    end
  end
  
end

class Criterion11Sec223fRefinanceTestClass
  include Criterion11::Sec223f::Refinance
end

describe Criterion11::Sec223f::Refinance do
  
  let(:valid_instance) do
    attrs = {:existing_indebtedness=>9_486_000, :repairs=>75_000, 
             :initial_deposit_to_replacement_reserve=>30_000, :legal_and_organizational=>15_000, 
             :title_and_recording=>10000, :third_party_reports=>10_000, :other=>10_000, :survey=>10_000,
             :fha_inspection_fee=>3_000, :financing_fee=> 1.5, :financing_fee_is_percent_of_loan=>true,
             :first_year_mortgage_insurance_premium_rate=>1, :exam_fee_rate=>0.3,
             :permanent_placement_rate => 0.5, :mortgagable_bond_costs_rate=>0.5,
             :discounts_rate=>0.5, :replacement_reserves_on_deposit=>100_000, 
             :major_movable_equipment=>45_000, :value_in_fee_simple=>12_000_000, :percent_multiplier=>80}
    Criterion11Sec223fRefinanceTestClass.new attrs
  end
  
  it_behaves_like "any implementation of Criterion11"
  it_behaves_like "any full implementation of Criterion11"
  
  specify {valid_instance.should be_a_kind_of Criterion10}
  
  describe "private_loans" do
    
    before do
      valid_instance.value_in_fee_simple = 7_000_000
      valid_instance.private_loans = 3_000_000
    end
    
    it "should be in error if, when added to the mortgage amount, it exceeds 92.5% of value" do
      max = valid_instance.value_in_fee_simple * 0.925
      valid_instance.should_not be_valid
      expected_msg = "when added to the mortgage amount must not exceed 92.5%" + 
                     " of project value (#{max})"
      valid_instance.errors[:private_loans].should == [expected_msg]
    end
    
    context "when other errors already present" do
      it "should be have no errors" do
        valid_instance.repairs = -1
        valid_instance.should_not be_valid
        (valid_instance.errors[:private_loans].empty?).should be true
      end
    end
    
  end
  
  describe "project_cost" do
    context "line_b7 is nil" do
      it "should be 100% the transaction costs less any RFR or major moveable on deposit" do
        valid_instance.project_cost.should be_within(0.005).of 9_931_000
      end
    end
    
    context "line_b7 is not nil" do
      it "should be < 100% the transaction costs less any RFR or major moveable on deposit" do
        valid_instance.should_receive(:line_b7).twice.and_return 1_000_000
        valid_instance.project_cost.should be < 9_931_000
        valid_instance.project_cost.should be > 0
      end
    end
  end
  
  describe "line_a" do
    it "should be an alias for project_cost" do
      valid_instance.should_receive(:project_cost).and_return some_int = 12345
      valid_instance.line_a.should == some_int
    end
  end
  
end