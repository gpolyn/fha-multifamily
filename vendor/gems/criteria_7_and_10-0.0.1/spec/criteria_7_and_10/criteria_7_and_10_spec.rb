require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "Criteria7And10.inspection_fee" do
  
  before(:all) do 
    @some_int = 1_000
    class TestClass; extend Criteria7And10::ClassMethods; end
  end
  
  it "should be nil when no apartments" do
    TestClass.inspection_fee(:repairs=>@some_int).should be nil
  end
  
  it "should be nil when apartments is 0" do
    TestClass.inspection_fee(:repairs=>@some_int, :total_apartments=>0).should be nil
  end
  
  it "should be 0 when repairs is 0" do
    TestClass.inspection_fee(:repairs=>0, :total_apartments=>@some_int).should == 0
  end
  
  it "should be nil when no repairs" do
    TestClass.inspection_fee(:total_apartments=>@some_int).should be nil
  end
  
  context "when the repairs per apartment is less than 3000" do
    it "should be the product of 30 and the number of apartments" do
      total_apartments, repairs = 100, 299_999.99
      (repairs/total_apartments).should be < 3_000
      result = TestClass.inspection_fee(:total_apartments=>total_apartments, :repairs=>repairs)
      result.should be_within(0.005).of(total_apartments * 30)
    end
  end
  
  context "when the repairs per apartment is equal to 3000" do
    it "should be 1% of the repair amount" do
      total_apartments, repairs = 100, 300_000.00
      (repairs/total_apartments).should be_within(0.005).of(3_000)
      result = TestClass.inspection_fee(:total_apartments=>total_apartments, :repairs=>repairs)
      result.should be_within(0.005).of(0.01 * repairs)
    end
  end
  
end

describe "criteria_7_and_10" do
  
  before(:each) do
    class TestClass; include Criteria7And10; end
    @testImpl = TestClass.new
    @some_int = 2_000_000
  end
  
  describe "validations" do
    
    before(:each) do
      @testImpl.percent_multiplier = 50.0
      @testImpl.first_year_mortgage_insurance_premium_rate = 0.45
    end
    
    after(:each) do
      @testImpl.should_not be_valid
      @testImpl.errors.size.should equal 1
      @testImpl.errors[@attr_sym].should == [@error_msg]
    end
    
    describe "financing_fee_is_percent_of_loan" do
      it "should not be valid if it is not in {true, false, nil}" do
        @testImpl.financing_fee_is_percent_of_loan = 34
        @attr_sym = :financing_fee_is_percent_of_loan
        @error_msg = "must be one of true, false or nil"
      end
    end
    
    describe "title_and_recording_is_percent_of_loan" do
      it "should not be valid if it is not in {true, false, nil}" do
        @testImpl.title_and_recording_is_percent_of_loan = 34
        @attr_sym = :title_and_recording_is_percent_of_loan
        @error_msg = "must be one of true, false or nil"
      end
    end
    
    it "should require presence of valid percent_multiplier" do
      @testImpl.percent_multiplier = nil
      @attr_sym = :percent_multiplier
      @error_msg = "is not a number"
    end
    
    it "should require presence of valid first_year_mortgage_insurance_premium_rate" do
      @testImpl.first_year_mortgage_insurance_premium_rate = nil
      @attr_sym = :first_year_mortgage_insurance_premium_rate
      @error_msg = "is not a number"
    end
    
    describe "attributes required to be 100 or less" do
      
      before(:each) do
        @too_high_decimal = 100.01
        @error_msg = "must be less than or equal to 100"
      end
      
      it "should include title_and_recording if title_and_recording_is_percent_of_loan is true" do
        @testImpl.title_and_recording_is_percent_of_loan = true
        @testImpl.title_and_recording = @too_high_decimal
        @attr_sym = :title_and_recording
      end
      
      it "should include financing_fee if financing_fee_is_percent_of_loan is true" do
        @testImpl.financing_fee_is_percent_of_loan = true
        @testImpl.financing_fee = @too_high_decimal
        @attr_sym = :financing_fee
      end
      
      it "should include first_year_mortgage_insurance_premium_rate" do
        @testImpl.first_year_mortgage_insurance_premium_rate = @too_high_decimal
        @attr_sym = :first_year_mortgage_insurance_premium_rate
      end
      
      it "should include exam_fee_rate" do
        @testImpl.exam_fee_rate = @too_high_decimal
        @attr_sym = :exam_fee_rate
      end
      
      it "should include mortgagable_bond_costs_rate" do
        @testImpl.mortgagable_bond_costs_rate = @too_high_decimal
        @attr_sym = :mortgagable_bond_costs_rate
      end
      
      it "should include discounts_rate" do
        @testImpl.discounts_rate = @too_high_decimal
        @attr_sym = :discounts_rate
      end
      
      it "should include permanent_placement_rate" do
        @testImpl.permanent_placement_rate = @too_high_decimal
        @attr_sym = :permanent_placement_rate
      end
      
    end
    
    describe "attributes required to be 0 or greater" do
      
      before(:each) do
        @negative_decimal = -0.01
        @error_msg = "must be greater than or equal to 0"
      end
      
      it "should include percent_multiplier" do
        @testImpl.percent_multiplier = @negative_decimal
        @attr_sym = :percent_multiplier
      end
      
      it "should include third_party_reports" do
        @testImpl.third_party_reports = @negative_decimal
        @attr_sym = :third_party_reports
      end
      
      it "should include other" do
        @testImpl.other = @negative_decimal
        @attr_sym = :other
      end
      
      it "should include survey" do
        @testImpl.survey = @negative_decimal
        @attr_sym = :survey
      end
      
      it "should include replacement_reserves_on_deposit" do
        @testImpl.replacement_reserves_on_deposit = @negative_decimal
        @attr_sym = :replacement_reserves_on_deposit
      end
      
      it "should include major_movable_equipment" do
        @testImpl.replacement_reserves_on_deposit = @negative_decimal
        @attr_sym = :replacement_reserves_on_deposit
      end
      
      it "should include initial_deposit_to_replacement_reserve" do
        @testImpl.initial_deposit_to_replacement_reserve = @negative_decimal
        @attr_sym = :initial_deposit_to_replacement_reserve
      end
      
      it "should include title_and_recording" do
        @testImpl.title_and_recording = @negative_decimal
        @attr_sym = :title_and_recording
      end
      
      it "should include financing_fee" do
        @testImpl.financing_fee = @negative_decimal
        @attr_sym = :financing_fee
      end
      
      it "should include legal_and_organizational" do
        @testImpl.legal_and_organizational = @negative_decimal
        @attr_sym = :legal_and_organizational
      end
      
      it "should include first_year_mortgage_insurance_premium_rate" do
        @testImpl.first_year_mortgage_insurance_premium_rate = @negative_decimal
        @attr_sym = :first_year_mortgage_insurance_premium_rate
      end
      
      it "should include exam_fee_rate" do
        @testImpl.exam_fee_rate = @negative_decimal
        @attr_sym = :exam_fee_rate
      end
      
      it "should include mortgagable_bond_costs_rate" do
        @testImpl.mortgagable_bond_costs_rate = @negative_decimal
        @attr_sym = :mortgagable_bond_costs_rate
      end
      
      it "should include discounts_rate" do
        @testImpl.discounts_rate = @negative_decimal
        @attr_sym = :discounts_rate
      end
      
      it "should include permanent_placement_rate" do
        @testImpl.permanent_placement_rate = @negative_decimal
        @attr_sym = :permanent_placement_rate
      end
      
    end
    
  end

  describe "other_fees" do
    it "should be the sum of fha_inspection_fee, third_party_reports, survey & other" do
      expected = @testImpl.fha_inspection_fee = @some_int
      expected += @testImpl.third_party_reports = @some_int
      expected += @testImpl.survey = @some_int
      expected += @testImpl.other = @some_int
      @testImpl.other_fees.should == expected
    end
    
    it "should be nil if none of the fee items are present" do
      @testImpl.fha_inspection_fee = nil
      @testImpl.third_party_reports = nil
      @testImpl.survey = nil
      @testImpl.other = nil
      @testImpl.other_fees.should be nil
    end
    
    it "should be the fha_inspection_fee" do
      expected = @testImpl.fha_inspection_fee = @some_int
      @testImpl.other_fees.should == expected
    end
    
    it "should be third_party_reports" do
      @testImpl.third_party_reports = @some_int
      @testImpl.other_fees.should == @some_int
    end
    
    it "should be survey" do
      @testImpl.survey = @some_int
      @testImpl.other_fees.should == @some_int
    end
    
    it "should be other" do
      @testImpl.other = @some_int
      @testImpl.other_fees.should == @some_int
    end
  end
  
  describe "line_c" do
    it "should be an alias for other_fees" do
      @testImpl.other = @some_int
      @testImpl.other_fees.should == @some_int
      @testImpl.line_c.should == @testImpl.other_fees
    end
  end
  
  describe "sum_of_lines_a_through_d" do
    
    it "should be nil when none of the line items are present" do
      @testImpl.stub(:line_a)
      @testImpl.stub(:line_d)
      @testImpl.stub(:line_b)
      @testImpl.stub(:line_c)
      @testImpl.sum_of_lines_a_through_d.should be nil
    end
    
    context "at least one of the line items are present" do
      
      before(:each) do 
        @testImpl.should_receive(:line_a).any_number_of_times.and_return(@some_int)
        @testImpl.should_receive(:line_d).any_number_of_times.and_return(@some_int)
        @expected = @some_int * 2
      end
      
      it "should be the sum of line_a and line_d" do
        @testImpl.stub(:line_b)
        @testImpl.sum_of_lines_a_through_d.should == @expected
      end

      it "should be the sum of line_a, line_b, line_c & line_d" do
        @testImpl.stub(:line_b).and_return(@some_int)
        @testImpl.should_receive(:line_c).and_return(@some_int)
        @expected += @some_int * 2
        @testImpl.sum_of_lines_a_through_d.should == @expected
      end
    end
  end
  
  describe "line_e" do
    it "should be an alias for sum_of_lines_a_through_d" do
      @testImpl.stub(:line_b)
      @testImpl.should_receive(:line_a).any_number_of_times.and_return(@some_int)
      @testImpl.should_receive(:line_d).any_number_of_times.and_return(@some_int)
      @testImpl.sum_of_lines_a_through_d.should == @some_int * 2
      @testImpl.sum_of_lines_a_through_d.should == @testImpl.line_e
    end
  end
  
  describe "sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment" do
    
    it "should be the sum of the two items" do
      @testImpl.replacement_reserves_on_deposit = @some_int - 1
      @testImpl.major_movable_equipment = @some_int + 1
      expected = @testImpl.replacement_reserves_on_deposit + @testImpl.major_movable_equipment
      @testImpl.sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment.should == expected
    end
    
    it "should be replacement_reserves_on_deposit" do
      @testImpl.replacement_reserves_on_deposit = @some_int
      @testImpl.sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment.should == @testImpl.replacement_reserves_on_deposit
    end
    
    it "should be major_movable_equipment" do
      @testImpl.major_movable_equipment = @some_int
      @testImpl.sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment.should == @testImpl.major_movable_equipment
    end
    
    it "should be nil when neither present" do
      @testImpl.replacement_reserves_on_deposit = nil
      @testImpl.major_movable_equipment = nil
      @testImpl.sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment.should be nil
    end
  end
  
  describe "line_f" do
    it "should be an alias for sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment" do
      @testImpl.major_movable_equipment = @some_int
      @testImpl.line_f.should == @testImpl.sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment
    end
  end
  
  describe "line_g" do
    
    it "should be the difference between line_e and line_f" do
      @testImpl.should_receive(:line_e).any_number_of_times.and_return(@some_int * 2)
      @testImpl.should_receive(:line_f).any_number_of_times.and_return(@some_int)
      @testImpl.line_g.should == @testImpl.line_e - @testImpl.line_f
    end
    
    it "should be nil when line e is not present" do
      @testImpl.stub(:line_e)
      @testImpl.should_receive(:line_f).any_number_of_times.and_return(@some_int)
      @testImpl.line_g.should be nil
    end
    
    it "should be line_e" do
      @testImpl.should_receive(:line_e).any_number_of_times.and_return(@some_int)
      @testImpl.line_g.should == @testImpl.line_e
    end
    
  end
  
end