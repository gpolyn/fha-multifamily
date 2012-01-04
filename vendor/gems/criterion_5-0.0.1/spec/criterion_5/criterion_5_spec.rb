require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "Criterion5::debt_service_constant_percent" do
  it "should be the same as some Excel spreadsheet result for the same inputs" do
    args = {:mortgage_interest_rate=>5.5, :mortgage_insurance_premium_rate=>0.45, :term_in_months=>420}
    result = Criterion5::debt_service_constant_percent(args)
    result.should be_within(0.00005).of(6.8942)
  end
end

describe "criterion_5" do
  
  before(:each) do
    @criterion_5 = Criterion5::Criterion5.new(:mortgage_interest_rate=>5.15, 
                                              :mortgage_insurance_premium_rate=>0.45,
                                              :debt_service_constant=>6.81)
    @some_int = 1_000_000
  end
  
  describe "as_json" do
    
    it "should have expected 0 or nil values when minimal, valid data is supplied" do
      attrs = {:mortgage_interest_rate=>0, :mortgage_insurance_premium_rate=>0, :operating_expenses=> 0,
               :debt_service_constant=>0, :effective_income=>0, :percent_multiplier=>0}
      @criterion_5 = Criterion5::Criterion5.new attrs
      @criterion_5.should be_valid
      json = @criterion_5.as_json
      json[:line_a][:mortgage_interest_rate].should == attrs[:mortgage_interest_rate]
      json[:line_b][:mortgage_insurance_premium_rate].should == attrs[:mortgage_insurance_premium_rate]
      json[:line_c][:initial_curtail_rate].should == 0 # be_within(0.0000000005).of @criterion_5.initial_curtail_rate
      json[:line_d][:sum_of_above_rates].should == 0
      json[:line_e][:net_income].should == 0
      json[:line_e][:effective_income].should == attrs[:effective_income]
      json[:line_e][:percent_multiplier].should == attrs[:percent_multiplier]
      json[:line_f][:annual_ground_rent].should be nil
      json[:line_f][:annual_special_assessment].should be nil
      json[:line_f][:sum].should be nil
      json[:line_g][:line_e_minus_line_f].should == 0
      json[:line_h][:line_g_divided_by_line_d].should be nil
      json[:line_i][:annual_tax_abatement].should be nil
      json[:line_j][:line_h_plus_line_i].should be nil
    end
    
    it "should be comprised of expected values when all data supplied" do
      attrs = {:mortgage_interest_rate=>5.15, :mortgage_insurance_premium_rate=>0.45, :operating_expenses=> 450_000,
               :debt_service_constant=>6.21, :effective_income=>750_000, :percent_multiplier=>101,
               :annual_special_assessment=>45_000,
               :tax_abatement_present_value=>90_000, :annual_ground_rent=>40_000}
      @criterion_5 = Criterion5::Criterion5.new attrs
      @criterion_5.should be_valid
      json = @criterion_5.as_json
      json[:line_a][:mortgage_interest_rate].should == attrs[:mortgage_interest_rate]
      json[:line_b][:mortgage_insurance_premium_rate].should == attrs[:mortgage_insurance_premium_rate]
      json[:line_c][:initial_curtail_rate].should be_within(0.0000000005).of @criterion_5.initial_curtail_rate
      json[:line_d][:sum_of_above_rates].should == attrs[:debt_service_constant]
      json[:line_e][:net_income].should == @criterion_5.net_income
      json[:line_e][:effective_income].should == @criterion_5.line_e
      json[:line_e][:percent_multiplier].should == attrs[:percent_multiplier]
      json[:line_f][:annual_ground_rent].should == attrs[:annual_ground_rent]
      json[:line_f][:annual_special_assessment].should == attrs[:annual_special_assessment]
      json[:line_f][:sum].should be > 0
      json[:line_g][:line_e_minus_line_f].should == @criterion_5.line_g
      json[:line_h][:line_g_divided_by_line_d].should == @criterion_5.line_h
      json[:line_i][:tax_abatement_present_value].should == attrs[:tax_abatement_present_value]
      json[:line_j][:line_h_plus_line_i].should == @criterion_5.line_h_plus_line_i
    end
  end
  
  describe "validations" do
    
    before(:each) do
      minimumParametersRequired = {:mortgage_interest_rate => 0, :percent_multiplier => 0,
                                   :debt_service_constant => 0, :mortgage_insurance_premium_rate => 0,
                                   :effective_income => 0, :operating_expenses => 0}
      @criterion_5 = Criterion5::Criterion5.new(minimumParametersRequired)
    end
    
    after(:each) do
      @criterion_5.should_not be_valid
      @criterion_5.errors.size.should equal 1
      @criterion_5.errors[@attr_sym].should == [@error_msg]
    end
    
    describe "required attributes" do
      before(:each) {@error_msg = "is not a number"}
      
      it "should include mortgage_interest_rate" do
        @criterion_5.mortgage_interest_rate = nil
        @attr_sym = :mortgage_interest_rate
      end
      
      it "should include percent_multiplier" do
        @criterion_5.percent_multiplier = nil
        @attr_sym = :percent_multiplier
      end
      
      it "should include debt_service_constant" do
        @criterion_5.debt_service_constant = nil
        @attr_sym = :debt_service_constant
      end
      
      it "should include mortgage_insurance_premium_rate" do
        @criterion_5.mortgage_insurance_premium_rate = nil
        @attr_sym = :mortgage_insurance_premium_rate
      end
      
      it "should include effective_income" do
        @criterion_5.effective_income = nil
        @attr_sym = :effective_income
      end
      
      it "should include operating_expenses" do
        @criterion_5.operating_expenses = nil
        @attr_sym = :operating_expenses
      end
    end
    
    describe "attributes that must be 0 or greater" do
      before(:each) do
        @error_msg = "must be greater than or equal to 0"
        @negative_number = -0.01
      end
      
      it "should include mortgage_interest_rate" do
        @criterion_5.mortgage_interest_rate = @negative_number
        @attr_sym = :mortgage_interest_rate
      end
      
      it "should include percent_multiplier" do
        @criterion_5.percent_multiplier = @negative_number
        @attr_sym = :percent_multiplier
      end
      
      it "should include debt_service_constant" do
        @criterion_5.debt_service_constant = @negative_number
        @attr_sym = :debt_service_constant
      end
      
      it "should include mortgage_insurance_premium_rate" do
        @criterion_5.mortgage_insurance_premium_rate = @negative_number
        @attr_sym = :mortgage_insurance_premium_rate
      end
      
      it "should include effective_income" do
        @criterion_5.effective_income = @negative_number
        @attr_sym = :effective_income
      end
      
      it "should include operating_expenses" do
        @criterion_5.operating_expenses = @negative_number
        @attr_sym = :operating_expenses
      end
      
      it "should include annual_replacement_reserve" do
        @criterion_5.annual_replacement_reserve = @negative_number
        @attr_sym = :annual_replacement_reserve
      end
      
      it "should include annual_tax_abatement" do
        @criterion_5.annual_tax_abatement = @negative_number
        @attr_sym = :annual_tax_abatement
      end
      
      it "should include annual_ground_rent" do
        @criterion_5.annual_ground_rent = @negative_number
        @attr_sym = :annual_ground_rent
      end
      
      it "should include annual_special_assessment" do
        @criterion_5.annual_special_assessment = @negative_number
        @attr_sym = :annual_special_assessment
      end
      
      it "should include tax_abatement_present_value" do
        @criterion_5.tax_abatement_present_value = @negative_number
        @attr_sym = :tax_abatement_present_value
      end
    end
    
    describe "attributes that must be 100 or less" do
      before(:each) do
        @error_msg = "must be less than or equal to 100"
        @number_greater_than_100 = 100.01
      end
      
      it "should include mortgage_interest_rate" do
        @criterion_5.mortgage_interest_rate = @number_greater_than_100
        @attr_sym = :mortgage_interest_rate
      end
      
      it "should include mortgage_insurance_premium_rate" do
        @criterion_5.mortgage_insurance_premium_rate = @number_greater_than_100
        @attr_sym = :mortgage_insurance_premium_rate
      end
      
      it "should include debt_service_constant" do
        @criterion_5.debt_service_constant = @number_greater_than_100
        @attr_sym = :debt_service_constant
      end
    end
  end
  
  describe "when both annual_tax_abatement and tax_abatement_present_value are present" do
    it "should have an error on each of annual tax abatement and tax abatement present value" do
      @criterion_5.annual_tax_abatement = @some_int
      @criterion_5.tax_abatement_present_value = @some_int
      @criterion_5.should_not be_valid
      @criterion_5.errors[:annual_tax_abatement].should == ["is mutually exclusive with tax_abatement_present_value"]
      @criterion_5.errors[:tax_abatement_present_value].should == ["is mutually exclusive annual_tax_abatement"]
    end
  end
  
  describe "net_income" do
    
    before(:each) do
      @expected = @criterion_5.effective_income = 100_000
      @expected -= @criterion_5.operating_expenses = 50_000
    end
    
    it "should be income less opex plus annual_tax_abatement less annual_replacement_reserve" do
      @expected += @criterion_5.annual_tax_abatement = 500
      @expected -= @criterion_5.annual_replacement_reserve = 1_000
      @criterion_5.net_income.should == @expected
    end
    
    it "should be income less opex plus annual_tax_abatement" do
      @expected += @criterion_5.annual_tax_abatement = 500
      @criterion_5.net_income.should == @expected
    end
    
    it "should be income less opex less annual_replacement_reserve" do
      @expected -= @criterion_5.annual_replacement_reserve = 1_000
      @criterion_5.net_income.should == @expected
    end
    
    it "should return nil when not both of opex and effective gross income" do
      @criterion_5.effective_income = nil
      @criterion_5.operating_expenses = nil
      @criterion_5.net_income.should be nil
    end
    
  end
  
  describe "line_a" do    
    it "should be an alias for mortgage_interest_rate" do
      @criterion_5.line_a.should be_within(0.005).of(@criterion_5.mortgage_interest_rate)
    end
  end
  
  describe "line_b" do
    it "should be an alias for mortgage_insurance_premium_rate" do
      @criterion_5.line_b.should be_within(0.005).of(@criterion_5.mortgage_insurance_premium_rate)
    end
  end
  
  describe "initial_curtail_rate" do
    it "should be the debt_service_constant less the mortgage_insurance_premium_rate and mortgage_interest_rate" do
      expected = @criterion_5.debt_service_constant - @criterion_5.mortgage_insurance_premium_rate -
                 @criterion_5.mortgage_interest_rate
      @criterion_5.initial_curtail_rate.should be_within(0.005).of(expected)
    end
    
    context "not all of mip, interest rate and debt service constant present" do
      after(:each) {@criterion_5.initial_curtail_rate.should be nil}
      
      it "should be nil when mip absent" do
        @criterion_5.debt_service_constant = 7.8
        @criterion_5.mortgage_insurance_premium_rate = nil
        @criterion_5.mortgage_interest_rate = 5.45
      end
      
      it "should be nil when debt_service_constant absent" do
        @criterion_5.debt_service_constant = nil
        @criterion_5.mortgage_insurance_premium_rate = 0.45
        @criterion_5.mortgage_interest_rate = 5.45
      end
      
      it "should be nil when mortgage_interest_rate absent" do
        @criterion_5.debt_service_constant = 6.81
        @criterion_5.mortgage_insurance_premium_rate = 0.45
        @criterion_5.mortgage_interest_rate = nil
      end
      
    end
  end
  
  describe "line_c" do
    it "should be an alias for initial_curtail_rate" do
      @criterion_5.line_c.should be_within(0.005).of(@criterion_5.initial_curtail_rate)
    end
  end
  
  describe "line_d" do
    it "should be an alias for debt_service_constant" do
      @criterion_5.line_d.should be_within(0.005).of(@criterion_5.debt_service_constant)
    end
  end
  
  describe "line_e" do
    it "should be the product of net_income and the percent_multiplier" do
      @criterion_5.should_receive(:net_income).and_return(@some_int)
      @criterion_5.percent_multiplier = 87.5
      expected = @some_int * @criterion_5.percent_multiplier/100
      @criterion_5.line_e.should be_within(0.005).of(expected)
    end
    
    it "should be nil when net income nil" do
      @criterion_5.effective_income = nil
      @criterion_5.operating_expenses = nil
      @criterion_5.line_e.should be nil
    end
    
    it "should be nil when percent_multipler nil" do
      @criterion_5.effective_income = 1_000_000
      @criterion_5.operating_expenses = 500_000
      @criterion_5.percent_multiplier = nil
      @criterion_5.line_e.should be nil
    end
  end
  
  describe "line_f" do
    it "should be the sum of annual_ground_rent and annual_special_assessment" do
      @criterion_5.annual_ground_rent = @some_int - 1
      @criterion_5.annual_special_assessment = @some_int + 1
      expected = @criterion_5.annual_special_assessment + @criterion_5.annual_ground_rent
      @criterion_5.line_f.should == @criterion_5.line_f
    end
    
    it "should be the annual_ground_rent" do
      @criterion_5.annual_ground_rent = @some_int
      @criterion_5.line_f.should == @criterion_5.annual_ground_rent
    end
    
    it "should be the annual_special_assessment" do
      @criterion_5.annual_special_assessment = @some_int
      @criterion_5.line_f.should == @criterion_5.annual_special_assessment
    end
    
    it "should be nil when neither summand present" do
      @criterion_5.line_f.should be nil
    end
  end
  
  describe "line_g" do
    it "should be line_e less line_f" do
      @criterion_5.should_receive(:line_e).and_return(@some_int * 2)
      @criterion_5.should_receive(:line_f).and_return(@some_int)
      expected = @some_int
      @criterion_5.line_g.should == expected
    end
    
    it "should be line_e when line_f is nil" do
      @criterion_5.should_receive(:line_e).and_return(@some_int)
      @criterion_5.should_receive(:line_f).and_return(nil)
      @criterion_5.line_g.should == @some_int
    end
    
    it "should be nil when line_e is nil" do
      @criterion_5.should_receive(:line_e).and_return(nil)
      @criterion_5.should_receive(:line_f).any_number_of_times.and_return(@some_int)
      @criterion_5.line_g.should be nil
    end
  end
  
  describe "line_h" do
    it "should be line_g divided by line_d expressed as a rate" do
      @criterion_5.should_receive(:line_g).and_return(@some_int)
      expected = @some_int/(@criterion_5.line_d.to_f/100)
      @criterion_5.line_h.should be_within(0.005).of(expected)
    end
    
    it "should be nil when line_d == 0" do
      @criterion_5.should_receive(:line_g).and_return(@some_int)
      @criterion_5.should_receive(:line_d).and_return 0
      @criterion_5.line_h.should be nil
    end
    
    it "should be nil when no line_g" do
      @criterion_5.should_receive(:line_g).and_return(nil)
      @criterion_5.line_h.should be nil
    end
    
    it "should be nil when no line_d" do
      @criterion_5.should_receive(:line_d).and_return nil
      @criterion_5.should_receive(:line_g).and_return(1_000_000)
      @criterion_5.line_h.should be nil
    end
  end
  
  describe "line_h_plus_line_i" do
    it "should be line_h plus line_i to the lowest 100" do
      @criterion_5.should_receive(:line_h).and_return(1_000)
      @criterion_5.should_receive(:line_i).and_return(199)
      expected = 1_100
      @criterion_5.line_h_plus_line_i.should == expected
    end
    
    it "should be line_h to the lowest 100" do
      @criterion_5.should_receive(:line_h).and_return(1_099)
      @criterion_5.line_h_plus_line_i.should == 1_000
    end
    
    it "should be nil when line_h is nil" do
      @criterion_5.should_receive(:line_h).and_return nil
      @criterion_5.should_receive(:line_i).any_number_of_times.and_return(199)
      @criterion_5.line_h_plus_line_i.should be nil
    end
  end
  
  describe "line_j" do
    it "should be be an alias for line_h_plus_line_i" do
      @criterion_5.should_receive(:line_h).any_number_of_times.and_return(1_000)
      @criterion_5.should_receive(:line_i).any_number_of_times.and_return(199)
      expected = 1_100
      @criterion_5.line_j.should == @criterion_5.line_h_plus_line_i
    end
  end
  
end