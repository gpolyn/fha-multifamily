require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "criterion_7" do
  
  before(:each) do
    @criterion_7 = Criterion7::Criterion7.new(:percent_multiplier=>50.0)
    @some_int = 2_000_000
  end
  
  it "should include Criteria7And10" do
    Criterion7::Criterion7.include?(Criteria7And10).should be true
  end
  
  it "should include Criteria7And10::ClassMethods.inspection_fee" do
    Criterion7.respond_to?(:inspection_fee).should be true
  end
  
  describe "as_json" do
    
    it "should have expected values when all inputs given (arbitrarily, optional attributes in $)" do
      attrs = {:purchase_price_of_project=>10_000_000, :repairs_and_improvements=>75_000,
               :percent_multiplier=>101, :first_year_mortgage_insurance_premium_rate=>100,
               :exam_fee_rate=>100, :title_and_recording=>100, :title_and_recording_is_percent_of_loan=>true,
               :fha_inspection_fee=>75_000, :financing_fee=> 100, :financing_fee_is_percent_of_loan=>true,
               :legal_and_organizational=>40_000, :discounts_rate=>100,
               :permanent_placement_rate=>100, :third_party_reports=>15_000, :other=>15_000, :survey=>7_000,
               :replacement_reserves_on_deposit=>75_000, :major_movable_equipment=>75_000,
               :mortgagable_bond_costs_rate=>100, :initial_deposit_to_replacement_reserve=>40_000}
      criterion_7 = Criterion7::Criterion7.new attrs
      criterion_7.should be_valid
      json = criterion_7.as_json
      json[:line_a][:purchase_price_of_project].should == attrs[:purchase_price_of_project]
      json[:line_b][:repairs_and_improvements].should == attrs[:repairs_and_improvements]
      json[:line_c][:other_fees].should == criterion_7.line_c
      json[:line_d][:loan_closing_charges].should == criterion_7.line_d
      json[:line_e][:sum_of_line_a_through_line_d].should == criterion_7.line_e
      json[:line_f][:sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment].should == criterion_7.line_f
      json[:line_g][:line_e_minus_line_f].should be_within(0.005).of criterion_7.line_g
      json[:line_h][:percent_multiplier].should be attrs[:percent_multiplier]
      json[:line_h][:result].should be criterion_7.line_h
    end
    
    it "should have expected 0 or nil values when minimal, valid data is supplied" do
      attrs = {:purchase_price_of_project=>0,
               :percent_multiplier=>0, :first_year_mortgage_insurance_premium_rate=>0}
      criterion_7 = Criterion7::Criterion7.new attrs
      criterion_7.should be_valid
      json = criterion_7.as_json
      json[:line_a][:purchase_price_of_project].should == 0
      json[:line_b][:repairs_and_improvements].should == nil
      json[:line_c][:other_fees].should == nil
      json[:line_d][:loan_closing_charges].should == 0
      json[:line_e][:sum_of_line_a_through_line_d].should == 0
      json[:line_f][:sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment].should == nil
      json[:line_g][:line_e_minus_line_f].should == 0
      json[:line_h][:percent_multiplier].should == 0
      json[:line_h][:result].should == 0
    end
  end
  
  describe "validations" do
    
    before(:each) do
      @criterion_7 = Criterion7::Criterion7.new(:percent_multiplier=>50.0,
                                                :first_year_mortgage_insurance_premium_rate=>1,
                                                :purchase_price_of_project => @some_int)
    end
    
    after(:each) do
      @criterion_7.should_not be_valid
      @criterion_7.errors.size.should equal 1
      @criterion_7.errors[@attr_sym].should == [@error_msg]
    end
    
    it "should require presence of valid purchase_price_of_project" do
      @criterion_7.purchase_price_of_project = nil
      @attr_sym = :purchase_price_of_project
      @error_msg = "is not a number"
    end
    
    describe "attributes required to be 0 or greater" do
      before(:each) {@error_msg = "must be greater than or equal to 0"}
      
      it "should require purchase_price_of_project be zero or greater" do
        @criterion_7.purchase_price_of_project = -0.01
        @attr_sym = :purchase_price_of_project
      end

      it "should require repairs_and_improvements be zero or greater" do
        @criterion_7.repairs_and_improvements = -0.01
        @attr_sym = :repairs_and_improvements
      end
    end
    
  end
  
  describe "line_a" do
    it "should be an alias for purchase_price_of_project" do
      @criterion_7.purchase_price_of_project = @some_int
      @criterion_7.line_a.should == @criterion_7.purchase_price_of_project
    end
  end
  
  describe "line_b" do
    it "should be an alias for repairs_and_improvements" do
      @criterion_7.repairs_and_improvements = @some_int
      @criterion_7.line_b.should == @criterion_7.repairs_and_improvements
    end
  end
  
  describe "loan_closing_charges" do
    
    it "should be nil when loan closing charges are nil" do
      @criterion_7.percent_multiplier = nil
      @criterion_7.purchase_price_of_project = nil
      @criterion_7.repairs_and_improvements = nil
      @criterion_7.legal_and_organizational = nil
      @criterion_7.initial_deposit_to_replacement_reserve = nil
      @criterion_7.fha_inspection_fee = nil
      @criterion_7.third_party_reports = nil
      @criterion_7.survey = nil
      @criterion_7.other = nil
      @criterion_7.major_movable_equipment = nil
      @criterion_7.replacement_reserves_on_deposit = nil
      @criterion_7.first_year_mortgage_insurance_premium_rate = nil
      @criterion_7.discounts_rate = nil
      @criterion_7.mortgagable_bond_costs_rate = nil
      @criterion_7.permanent_placement_rate = nil
      @criterion_7.exam_fee_rate = nil
      @criterion_7.loan_closing_charges.should be nil
    end
    
    context "when all values are supplied" do
      before(:each) do
        @criterion_7.percent_multiplier = 85
        @criterion_7.purchase_price_of_project = 12_300_000
        @criterion_7.repairs_and_improvements = 75_000
        @criterion_7.legal_and_organizational = 15_000
        @criterion_7.initial_deposit_to_replacement_reserve = 30_000
        @criterion_7.fha_inspection_fee = 3_000
        @criterion_7.third_party_reports = 15_000
        @criterion_7.survey = 5_000
        @criterion_7.other = 10_000
        @criterion_7.major_movable_equipment = 100_000
        @criterion_7.replacement_reserves_on_deposit = 45_000
        @criterion_7.first_year_mortgage_insurance_premium_rate = 1
        @criterion_7.discounts_rate = 1
        @criterion_7.mortgagable_bond_costs_rate = 0.75
        @criterion_7.permanent_placement_rate = 0.5
        @criterion_7.exam_fee_rate = 0.3
      end

      context "when costs optionally expressed as dollars are in rate" do
        it "should be result expected from '85_percent.xls' Fees-Purchase tab" do
          @criterion_7.title_and_recording = 0.0914093
          @criterion_7.title_and_recording_is_percent_of_loan = true
          @criterion_7.financing_fee = 1.5
          @criterion_7.financing_fee_is_percent_of_loan = true
          @criterion_7.loan_closing_charges.should be_within(0.05).of(607_459.9) # this lack of precision has to do with lower 100 restriction on loan
        end
      end

      context "when costs optionally expressed as rate are in dollars" do
        it "should be result expected from '85_percent.xls' Fees-Purchase tab" do
          @criterion_7.title_and_recording = 10_000
          @criterion_7.financing_fee = 164_097
          @criterion_7.loan_closing_charges.should be_within(0.005).of(607_459.9)
        end
      end
    end
    
  end
  
  describe "line_d" do
    it "should be an alias for loan_closing_charges" do
      @criterion_7.purchase_price_of_project = @some_int
      @criterion_7.first_year_mortgage_insurance_premium_rate = 0.9
      @criterion_7.line_d.should be_within(0.005).of(@criterion_7.loan_closing_charges)
    end
  end
  
  describe "line_h" do
    it "should be the product of line_g and the percent_multiplier to the lowest 100" do
      @criterion_7.should_receive(:line_g).any_number_of_times.and_return(@some_int)
      expected = ((@criterion_7.percent_multiplier.to_f/100 * @criterion_7.line_g)/100).truncate * 100
      @criterion_7.line_h.should == expected
    end
    
    it "should be nil when neither line_g or percent_multiplier are present" do
      @criterion_7.stub(:line_g)
      @criterion_7.stub(:percent_multiplier)
      @criterion_7.line_h.should be nil
    end
    
  end
end