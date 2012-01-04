require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "criterion_10" do
  
  before(:each) do
    @criterion_10 = Criterion10::Criterion10.new(:percent_multiplier=>50.0)
    @some_int = 2_000_000
  end
  
  it "should include Criteria7And10::ClassMethods.inspection_fee" do
    Criterion10.respond_to?(:inspection_fee).should be true
  end
  
  it "should include Criteria7And10" do
    Criterion10::Criterion10.include?(Criteria7And10).should be true
  end
  
  describe "as_json" do
    
    it "should have expected values when all inputs given (arbitrarily, optional attributes in $)" do
      attrs = {:existing_indebtedness=>10_000_000, :repairs=>75_000, :value_in_fee_simple=>12_000_000,
               :percent_multiplier=>101, :first_year_mortgage_insurance_premium_rate=>100,
               :exam_fee_rate=>100, :title_and_recording=>100, :title_and_recording_is_percent_of_loan=>true,
               :fha_inspection_fee=>75_000, :financing_fee_is_percent_of_loan=>true,
               :financing_fee=> 100, :legal_and_organizational=>40_000, :discounts_rate=>100,
               :permanent_placement_rate=>100, :third_party_reports=>15_000, :other=>15_000, :survey=>7_000,
               :replacement_reserves_on_deposit=>75_000, :major_movable_equipment=>75_000,
               :mortgagable_bond_costs_rate=>100, :initial_deposit_to_replacement_reserve=>40_000}
      criterion_10 = Criterion10::Criterion10.new attrs
      criterion_10.should be_valid
      json = criterion_10.as_json
      json[:line_a][:total_existing_indebtedness].should == attrs[:existing_indebtedness]
      json[:line_b][:required_repairs].should == attrs[:repairs]
      json[:line_c][:other_fees].should == criterion_10.line_c
      json[:line_d][:loan_closing_charges].should == criterion_10.line_d
      json[:line_e][:sum_of_line_a_through_line_d].should == criterion_10.line_e
      json[:line_f][:sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment].should == criterion_10.line_f
      json[:line_g][:line_e_minus_line_f].should be_within(0.005).of criterion_10.line_g
      json[:line_h][:value].should be_within(0.005).of criterion_10.value_in_fee_simple
      json[:line_h][:eighty_percent_multiplier].should be_within(0.005).of criterion_10.percent_multiplier
      json[:line_h][:result].should be_within(0.005).of criterion_10.eighty_percent_of_value
      json[:line_i][:greater_of_line_g_or_line_h].should be_within(0.005).of criterion_10.line_i
    end
    
    it "should have expected 0 or nil values when minimal, valid data is supplied" do
      attrs = {:existing_indebtedness=>0, :percent_multiplier=>0, :value_in_fee_simple=>0,
               :first_year_mortgage_insurance_premium_rate=>0}
      criterion_10 = Criterion10::Criterion10.new attrs
      criterion_10.should be_valid
      json = criterion_10.as_json
      json[:line_a][:total_existing_indebtedness].should be 0
      json[:line_b][:required_repairs].should be nil
      json[:line_c][:other_fees].should be nil
      json[:line_d][:loan_closing_charges].should be_within(0.005).of 0
      json[:line_e][:sum_of_line_a_through_line_d].should be_within(0.005).of 0
      json[:line_f][:sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment].should be nil
      json[:line_g][:line_e_minus_line_f].should be_within(0.005).of 0
      json[:line_h][:value].should be 0
      json[:line_h][:eighty_percent_multiplier].should be 0
      json[:line_h][:result].should be 0
      json[:line_i][:greater_of_line_g_or_line_h].should be_within(0.005).of 0
    end
  end
  
  describe "validations" do
    
    before(:each) do
      @criterion_10 = Criterion10::Criterion10.new(:percent_multiplier=>50.0,
                                                   :value_in_fee_simple=>1_000_000,
                                                   :first_year_mortgage_insurance_premium_rate=>1,
                                                   :existing_indebtedness => @some_int)
    end
    
    after(:each) do
      @criterion_10.should_not be_valid
      @criterion_10.errors.size.should equal 1
      @criterion_10.errors[@attr_sym].should == [@error_msg]
    end
    
    it "should require presence of valid existing_indebtedness" do
      @criterion_10.existing_indebtedness = nil
      @attr_sym = :existing_indebtedness
      @error_msg = "is not a number"
    end
    
    it "should require presence of valid value_in_fee_simple" do
      @criterion_10.value_in_fee_simple = nil
      @attr_sym = :value_in_fee_simple
      @error_msg = "is not a number"
    end
    
    describe "attributes required to be 0 or greater" do
      before(:each) {@error_msg = "must be greater than or equal to 0"}
      
      it "should include existing_indebtedness" do
        @criterion_10.existing_indebtedness = -0.01
        @attr_sym = :existing_indebtedness
      end
      
      it "should include value_in_fee_simple" do
        @criterion_10.value_in_fee_simple = -0.01
        @attr_sym = :value_in_fee_simple
      end

      it "should include repairs" do
        @criterion_10.repairs = -0.01
        @attr_sym = :repairs
      end
    end
    
  end
  
  describe "line_a" do
    it "should be an alias for existing_indebtedness" do
      @criterion_10.existing_indebtedness = @some_int
      @criterion_10.line_a.should == @criterion_10.existing_indebtedness
    end
  end
  
  describe "line_b" do
    it "should be an alias for repairs" do
      @criterion_10.repairs = @some_int
      @criterion_10.line_b.should == @criterion_10.repairs
    end
  end
  
  describe "loan_closing_charges" do
    
    it "should be nil when insufficient inputs supplied" do
      @criterion_10 = Criterion10::Criterion10.new
      @criterion_10.loan_closing_charges.should be nil
    end
    
    context "all values supplied" do
      before(:each) do
        @criterion_10.existing_indebtedness = 9_486_000
        @criterion_10.repairs = 75_000
        @criterion_10.legal_and_organizational = 15_000
        @criterion_10.initial_deposit_to_replacement_reserve = 30_000
        @criterion_10.fha_inspection_fee = 3_000
        @criterion_10.third_party_reports = 15_000
        @criterion_10.survey = 5_000
        @criterion_10.other = 10_000
        @criterion_10.major_movable_equipment = 100_000
        @criterion_10.replacement_reserves_on_deposit = 45_000
        @criterion_10.first_year_mortgage_insurance_premium_rate = 1
        @criterion_10.discounts_rate = 1
        @criterion_10.mortgagable_bond_costs_rate = 0.75
        @criterion_10.permanent_placement_rate = 0.5
        @criterion_10.exam_fee_rate = 0.3
      end

      context "when costs optionally expressed as dollars are in rate" do
        it "should be result expected from 'criterion 10.cost.xls' Fees-Refi tab" do
          @criterion_10.title_and_recording = 0.0999053
          @criterion_10.title_and_recording_is_percent_of_loan = true
          @criterion_10.financing_fee = 1.5
          @criterion_10.financing_fee_is_percent_of_loan = true
          @criterion_10.loan_closing_charges.should be_within(0.05).of(560_478.67)
        end
      end

      context "when costs optionally expressed as rate are in dollars" do
        it "should be result expected from 'criterion 10.cost.xls' Fees-Refi tab" do
          @criterion_10.title_and_recording = 10_000
          @criterion_10.financing_fee = 150_142.18
          @criterion_10.loan_closing_charges.should be_within(0.001).of(560_478.68)
        end
      end
    end
    
  end
  
  describe "line_d" do
    it "should be an alias for loan_closing_charges" do
      @criterion_10.existing_indebtedness = @some_int
      @criterion_10.first_year_mortgage_insurance_premium_rate = 0.9
      @criterion_10.line_d.should be_within(0.005).of(@criterion_10.loan_closing_charges)
    end
  end
  
  describe "line_g" do
    it "should be nil unless line_e" do
      @criterion_10.should_receive(:line_e).and_return nil
      @criterion_10.should_not_receive(:line_f)
      @criterion_10.line_g.should be nil
    end
    
    it "should be line_e rounded to lowest 100" do
      @criterion_10.should_receive(:line_e).and_return 10_000_099.99
      @criterion_10.should_receive(:line_f).and_return nil
      @criterion_10.line_g.should == 10_000_000
    end
    
    it "should be line_e minus line_f rounded to lowest 100" do
      @criterion_10.should_receive(:line_e).and_return 10_000_099.99
      @criterion_10.should_receive(:line_f).and_return 1_000_000
      @criterion_10.line_g.should == 9_000_000
    end
  end
  
  describe "line_e_minus_line_f" do
    it "should be an alias for line_g" do
      @criterion_10.stub(:line_e).and_return 10_000_099.99
      @criterion_10.stub(:line_f).and_return 1_000_000
      @criterion_10.line_g.should == expected = 9_000_000
      @criterion_10.line_e_minus_line_f.should == expected
    end
  end
  
  describe "line_h" do
    it "should be the product of value_in_fee_simple and the percent_multiplier to the lowest 100" do
      @criterion_10.value_in_fee_simple = value = 10_000_899
      expected = ((@criterion_10.percent_multiplier.to_f/100 * value)/100).truncate * 100
      @criterion_10.line_h.should == expected
    end
    
    it "should be nil unless percent_multiplier present" do
      @criterion_10.value_in_fee_simple = @some_int
      @criterion_10.percent_multiplier = nil
      @criterion_10.line_h.should be nil
    end
    
    it "should be nil unless value_in_fee_simple present" do
      @criterion_10.value_in_fee_simple = nil
      @criterion_10.percent_multiplier = 89
      @criterion_10.line_h.should be nil
    end
  end
  
  describe "eighty_percent_of_value" do
    it "should be an alias for line_h" do
      @criterion_10.value_in_fee_simple = value = 10_000_899
      @criterion_10.percent_multiplier = 80
      expected = @criterion_10.line_h
      @criterion_10.eighty_percent_of_value.should be_within(0.005).of(expected)
    end
  end
  
  describe "line_i" do
    it "should be the greater of line g or line h" do
      larger = @some_int + 1
      @criterion_10.should_receive(:line_g).any_number_of_times.and_return(@some_int)
      @criterion_10.should_receive(:line_h).any_number_of_times.and_return(larger)
      @criterion_10.line_h.should == larger
    end
    
    it "should be nil when neither line g or line h are present" do
      @criterion_10.stub(:line_g)
      @criterion_10.stub(:line_h)
      @criterion_10.line_h.should be nil
    end
  end
  
end