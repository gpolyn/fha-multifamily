shared_examples_for "any implementation of Criterion11" do
  
  let(:some_non_zero_positive_int) {12345}
  
  describe "attributes that cannot be negative" do
    
    after(:each) do
      valid_instance.should_not be_valid
      valid_instance.errors[@attr_sym].should == ["must be greater than or equal to 0"]
    end
    
    it "should include grants" do
      valid_instance.grants = -1
      @attr_sym = :grants
    end
    
    it "should include gifts" do
      valid_instance.gifts = -1
      @attr_sym = :gifts
    end
    
    it "should include private_loans" do
      valid_instance.private_loans = -1
      @attr_sym = :private_loans
    end
    
    it "should include value_of_leased_fee" do
      valid_instance.value_of_leased_fee = -1
      @attr_sym = :value_of_leased_fee
    end
    
    it "should include tax_credits" do
      valid_instance.tax_credits = -1
      @attr_sym = :tax_credits
    end
    
    it "should include cost_containment_mortgage_deduction" do
      valid_instance.cost_containment_mortgage_deduction = -1
      @attr_sym = :cost_containment_mortgage_deduction
    end
    
    it "should include excess_unusual_land_improvement" do
      valid_instance.excess_unusual_land_improvement = -1
      @attr_sym = :excess_unusual_land_improvement
    end
    
    it "should include unpaid_balance_of_special_assessment" do
      valid_instance.unpaid_balance_of_special_assessment = -1
      @attr_sym = :unpaid_balance_of_special_assessment
    end
  end
  
  describe "loans" do
    it "should be nil when neither public or private loans present" do
      valid_instance.loans.should be nil
    end
    
    it "should be private loans, when only that is present" do
      valid_instance.private_loans = some_non_zero_positive_int
      valid_instance.loans.should == some_non_zero_positive_int
    end
    
    it "should be public loans, when only that is present" do
      valid_instance.public_loans = some_non_zero_positive_int
      valid_instance.loans.should == some_non_zero_positive_int
    end
  end
  
  describe "grants_loans_gifts" do
    it "should be nil when no constituents" do
      valid_instance.grants_loans_gifts.should be nil
    end
    
    it "should be grants, when no other constituent present" do
      valid_instance.grants = some_non_zero_positive_int
      valid_instance.grants_loans_gifts.should == some_non_zero_positive_int
    end
    
    it "should be loans, when no other constituent present" do
      valid_instance.private_loans = some_non_zero_positive_int
      valid_instance.grants_loans_gifts.should == some_non_zero_positive_int
    end
    
    it "should be gifts, when no other constituent present" do
      valid_instance.gifts = some_non_zero_positive_int
      valid_instance.grants_loans_gifts.should == some_non_zero_positive_int
    end
  end
  
  describe "line_b1" do
    it "should be an alias for grants_loans_gifts" do
      valid_instance.gifts = some_non_zero_positive_int
      valid_instance.line_b1.should == some_non_zero_positive_int
    end
  end
  
  describe "line_b2" do
    it "should be an alias for tax_credits" do
      valid_instance.tax_credits = some_non_zero_positive_int
      valid_instance.line_b2.should == some_non_zero_positive_int
    end
  end
  
  describe "line_b3" do
    it "should be an alias for value_of_leased_fee" do
      valid_instance.value_of_leased_fee = some_non_zero_positive_int
      valid_instance.line_b3.should == some_non_zero_positive_int
    end
  end
  
  describe "line_b4" do
    it "should be an alias for excess_unusual_land_improvement" do
      valid_instance.excess_unusual_land_improvement = some_non_zero_positive_int
      valid_instance.line_b4.should == some_non_zero_positive_int
    end
  end
  
  describe "line_b5" do
    it "should be an alias for cost_containment_mortgage_deduction" do
      valid_instance.cost_containment_mortgage_deduction = some_non_zero_positive_int
      valid_instance.line_b5.should == some_non_zero_positive_int
    end
  end
  
  describe "line_b6" do
    it "should be an alias for unpaid_balance_of_special_assessment" do
      valid_instance.unpaid_balance_of_special_assessment = some_non_zero_positive_int
      valid_instance.line_b6.should == some_non_zero_positive_int
    end
  end
  
  describe "sum_of_lines_b1_through_b6" do
    it "should be nil when none of line_b1 through line_b6 are present" do
      valid_instance.sum_of_lines_b1_through_b6.should be nil
    end
    
    it "should be the sum of line_b1 through line_b6 when the items are present" do
      expected = valid_instance.gifts = some_non_zero_positive_int
      expected += valid_instance.tax_credits = some_non_zero_positive_int
      expected += valid_instance.value_of_leased_fee = some_non_zero_positive_int
      expected += valid_instance.excess_unusual_land_improvement = some_non_zero_positive_int
      expected += valid_instance.cost_containment_mortgage_deduction = some_non_zero_positive_int
      expected += valid_instance.unpaid_balance_of_special_assessment = some_non_zero_positive_int
      valid_instance.sum_of_lines_b1_through_b6.should be_within(0.005).of expected
    end
  end
  
  describe "line_b7" do
    it "should be an alias for sum_of_lines_b1_through_b6" do
      expected = valid_instance.tax_credits = some_non_zero_positive_int
      valid_instance.sum_of_lines_b1_through_b6.should be_within(0.005).of expected
    end
  end
  
  describe "line_a_minus_line_b7" do
    it "should be be nil when line_b7 is nil" do
      valid_instance.line_a_minus_line_b7.should be nil
    end
  end
  
  describe "line_c" do
    it "should be an alias for line_a_minus_line_b7" do
      valid_instance.should_receive(:line_a_minus_line_b7).and_return some_non_zero_positive_int
      valid_instance.line_c.should == some_non_zero_positive_int
    end
  end
  
end

shared_examples_for "any full implementation of Criterion11" do
  
  describe "line_a_minus_line_b7" do
    it "should be be difference of line_a and line_b7" do
      some_int = 5_000_000
      half_some_int = 2_500_000
      valid_instance.should_receive(:line_a).and_return some_int
      valid_instance.should_receive(:line_b7).and_return half_some_int
      valid_instance.line_a_minus_line_b7.should be half_some_int
    end
  end
  
  describe "as_json" do
    it "should be as it appears in the 2264a" do
      result = valid_instance.as_json
      result.size.should == 9
      result[:line_a] = {:project_cost=>valid_instance.line_a}
      result[:line_b1] = {:grants_loans_gifts=>valid_instance.line_b1}
      result[:line_b2] = {:tax_credits=>valid_instance.line_b2}
      result[:line_b3] = {:value_of_leased_fee=>valid_instance.line_b3}
      result[:line_b4] = {:excess_unusual_land_improvement_cost=>valid_instance.line_b4}
      result[:line_b5] = {:cost_containment_mortgage_deductions=>valid_instance.line_b5}
      result[:line_b6] = {:unpaid_balance_of_special_assessment=>valid_instance.line_b6}
      result[:line_b7] = {:sum_of_lines_1_through_6=>valid_instance.line_b7}
      result[:line_c] = {:line_a_minus_line_b=>valid_instance.line_c}
    end
  end
  
end