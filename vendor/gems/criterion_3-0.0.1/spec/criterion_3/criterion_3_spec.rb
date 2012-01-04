require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "criterion_3" do
  
  before(:each) do
    @criterion_3 = Criterion3::Criterion3.new(:percent_multiplier=>50.0)
    @some_int = 2_000_000
  end
  
  describe "as_json" do
    
    it "should have expected 0 or nil values when minimal, valid data is supplied" do
      criterion_3 = Criterion3::Criterion3.new(:value_in_fee_simple=>0, :percent_multiplier=>0)
      criterion_3.should be_valid
      json = criterion_3.as_json
      json[:line_a][:value_in_fee_simple].should == 0
      json[:line_a][:percent_multiplier].should == 0
      json[:line_a][:net_value].should == 0
      json[:line_b_1][:value_of_leased_fee].should be nil
      json[:line_b_3][:excess_unusual_land_improvement].should be nil
      json[:line_b_4][:cost_containment_mortgage_deduction].should be nil
      json[:line_b_5][:total_lines_1_to_4].should == nil
      json[:line_c][:unpaid_balance_of_special_assessments].should be nil
      json[:line_d][:total_line_b_plus_line_c].should be nil
      json[:line_e][:line_a_minus_line_d].should == 0
    end
    
    it "should be comprised of expected values when all data supplied" do
      attrs = {:value_in_fee_simple=>10_000_000, :percent_multiplier=>101, 
               :value_of_leased_fee=>50_000, :excess_unusual_land_improvement=>100_000,
               :cost_containment_mortgage_deduction=>75_000, 
               :unpaid_balance_of_special_assessments=> 40_000}
      criterion_3 = Criterion3::Criterion3.new attrs
      json = criterion_3.as_json
      json[:line_a][:value_in_fee_simple].should == attrs[:value_in_fee_simple]
      json[:line_a][:percent_multiplier].should == attrs[:percent_multiplier]
      json[:line_a][:net_value].should == criterion_3.total_line_a
      json[:line_b_1][:value_of_leased_fee].should == attrs[:value_of_leased_fee]
      json[:line_b_3][:excess_unusual_land_improvement].should == attrs[:excess_unusual_land_improvement]
      json[:line_b_4][:cost_containment_mortgage_deduction].should == attrs[:cost_containment_mortgage_deduction]
      json[:line_b_5][:total_lines_1_to_4].should == criterion_3.total_line_b
      json[:line_c][:unpaid_balance_of_special_assessments].should == attrs[:unpaid_balance_of_special_assessments]
      json[:line_d][:total_line_b_plus_line_c].should == criterion_3.line_d
      json[:line_e][:line_a_minus_line_d].should == criterion_3.line_e
    end
  end
  
  describe "validations" do
    
    before(:each) do
      minimumParametersRequired = {:value_in_fee_simple => 0, :percent_multiplier => 0}
      @criterion_3 = Criterion3::Criterion3.new(minimumParametersRequired)
      @negative_number = -0.01
    end
    
    after(:each) do
      @criterion_3.should_not be_valid
      @criterion_3.errors.size.should equal 1
      @criterion_3.errors[@attr_sym].should == [@error_msg]
    end
    
    describe "required attributes" do
      before(:each) {@error_msg = "is not a number"}
      
      it "should include value_in_fee_simple" do
        @criterion_3.value_in_fee_simple = nil
        @attr_sym = :value_in_fee_simple
      end
      it "should include percent_multiplier" do
        @criterion_3.percent_multiplier = nil
        @attr_sym = :percent_multiplier
      end
    end
    
    describe "attributes that must be 0 or greater" do
      before(:each) {@error_msg = "must be greater than or equal to 0"}
      
      it "should include value_in_fee_simple" do
        @criterion_3.value_in_fee_simple = @negative_number
        @attr_sym = :value_in_fee_simple
      end
      
      it "should include percent_multiplier" do
        @criterion_3.percent_multiplier = @negative_number
        @attr_sym = :percent_multiplier
      end

      it "should include value_of_leased_fee" do
        @criterion_3.value_of_leased_fee = @negative_number
        @attr_sym = :value_of_leased_fee
      end
      
      it "should include excess_unusual_land_improvement" do
        @criterion_3.excess_unusual_land_improvement = @negative_number
        @attr_sym = :excess_unusual_land_improvement
      end
      
      it "should include cost_containment_mortgage_deduction" do
        @criterion_3.cost_containment_mortgage_deduction = @negative_number
        @attr_sym = :cost_containment_mortgage_deduction
      end
      
      it "should include unpaid_balance_of_special_assessments" do
        @criterion_3.unpaid_balance_of_special_assessments = @negative_number
        @attr_sym = :unpaid_balance_of_special_assessments
      end
    end
    
  end
  
  describe "total_line_a" do
    
    it "should be the product of percent_multiplier and value_in_fee_simple" do
      @criterion_3.value_in_fee_simple = @some_int
      expected = @criterion_3.percent_multiplier/100 * @some_int
      @criterion_3.total_line_a.should be_within(0.005).of(expected)
    end
    
    it "should be nil when no value supplied" do
      @criterion_3.value_in_fee_simple = nil
      @criterion_3.percent_multiplier = 85
      @criterion_3.total_line_a.should be nil
    end
    
    it "should be nil when no percent multiplier supplied" do
      @criterion_3.value_in_fee_simple = 10_000_000
      @criterion_3.percent_multiplier = nil
      @criterion_3.total_line_a.should be nil
    end
    
  end
  
  describe "line_b_1" do
    it "should be an alias for value_of_leased_fee" do
      @criterion_3.value_of_leased_fee = @some_int
      @criterion_3.line_b_1.should == @some_int
    end
  end
  
  describe "line_b_3" do
    it "should be an alias for excess_unusual_land_improvement" do
      @criterion_3.excess_unusual_land_improvement = @some_int
      @criterion_3.line_b_3.should == @some_int
    end
  end
  
  describe "line_b_4" do
    it "should be an alias for cost_containment_mortgage_deduction" do
      @criterion_3.cost_containment_mortgage_deduction = @some_int
      @criterion_3.line_b_4.should == @some_int
    end
  end
  
  describe "total_line_b" do
    
    it "should be the product of percent_multiplier and all line b items" do
      sum = @criterion_3.value_of_leased_fee = @some_int + 1
      sum += @criterion_3.excess_unusual_land_improvement = @some_int - 1
      sum += @criterion_3.cost_containment_mortgage_deduction = @some_int
      expected = @criterion_3.percent_multiplier/100 * sum
      @criterion_3.total_line_b.should be_within(0.005).of(expected)
    end
    
    it "should be the product of percent_multiplier and value_of_leased_fee" do
      @criterion_3.value_of_leased_fee = @some_int
      expected = @criterion_3.percent_multiplier/100 * @some_int
      @criterion_3.total_line_b.should be_within(0.005).of(expected)
    end
    
    it "should be the product of percent_multiplier and cost_containment_mortgage_deduction" do
      @criterion_3.cost_containment_mortgage_deduction = @some_int
      expected = @criterion_3.percent_multiplier/100 * @some_int
      @criterion_3.total_line_b.should be_within(0.005).of(expected)
    end
    
    it "should be the product of percent_multiplier and excess_unusual_land_improvement" do
      @criterion_3.excess_unusual_land_improvement = @some_int
      expected = @criterion_3.percent_multiplier/100 * @some_int
      @criterion_3.total_line_b.should be_within(0.005).of(expected)
    end
    
    it "should be nil when none of lines b1 trough b 4 supplied" do
      @criterion_3.total_line_b.should be nil
    end
    
    it "should be nil when percent_multiplier not supplied" do
      @criterion_3.value_of_leased_fee = 100_000
      @criterion_3.percent_multiplier = nil
      @criterion_3.total_line_b.should be nil
    end
    
  end
  
  describe "line_c" do
    it "should be an alias for unpaid_balance_of_special_assessments " do
      @criterion_3.unpaid_balance_of_special_assessments = @some_int
      @criterion_3.line_c.should == @some_int
    end
  end
  
  describe "line_d" do
    it "should be the sum of total_line_b and line_c" do
      @criterion_3.should_receive(:total_line_b).any_number_of_times.and_return(@some_int)
      another_int = @some_int - 1
      @criterion_3.should_receive(:line_c).any_number_of_times.and_return(another_int)
      @criterion_3.line_d.should == @some_int + another_int
    end
    
    it "should be the sum of total_line_b" do
      @criterion_3.should_receive(:total_line_b).any_number_of_times.and_return(@some_int)
      @criterion_3.line_d.should == @some_int
    end
    
    it "should be line_c" do
      @criterion_3.should_receive(:line_c).any_number_of_times.and_return(@some_int)
      @criterion_3.line_d.should == @some_int
    end
    
    it "should be nil when neither line_c or total_line_b are present" do
      @criterion_3.should_receive(:total_line_b).any_number_of_times.and_return nil
      @criterion_3.should_receive(:line_c).any_number_of_times.and_return nil
      @criterion_3.line_d.should be nil
    end
    
  end
  
  describe "line_e" do
    it "should be the difference of line_a and line_d to the lowest 100" do
      @criterion_3.should_receive(:total_line_a).and_return(@some_int)
      another_int = @some_int - 120_345
      @criterion_3.should_receive(:line_d).and_return(another_int)
      expected = ((@some_int - another_int)/100).truncate * 100
      @criterion_3.line_e.should == expected
    end
    
    it "should be the difference of line_a to the lowest 100" do
      @criterion_3.should_receive(:total_line_a).and_return(@some_int)
      @criterion_3.should_receive(:line_d).and_return nil
      expected = (@some_int/100).truncate * 100
      @criterion_3.line_e.should == expected
    end
    
    it "should be nil when line a not present" do
      @criterion_3.should_receive(:total_line_a).and_return nil
      @criterion_3.should_receive(:line_d).any_number_of_times.and_return 100_000
      @criterion_3.line_e.should be nil
    end
  end
  
end