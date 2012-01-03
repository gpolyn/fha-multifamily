require 'spec_helper'
require File.dirname(__FILE__) + '/helpers'

RSpec.configure do |c|
  c.include Helpers
end
  
shared_examples_for "a generic sec 223f" do
  
  describe "after initialization" do
    it "the stat mortgage limits for elevator projects should be set" do
      TestClass.new minimum_params
      Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms.should == @elevator_stat_limits.zero_bedroom
      Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms.should == @elevator_stat_limits.one_bedroom
      Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms.should == @elevator_stat_limits.two_bedroom
      Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms.should == @elevator_stat_limits.three_bedroom
      Criterion4::StatutoryMortgageLimits.elevator_4_bedrooms.should == @elevator_stat_limits.four_bedroom
    end

    it "the stat mortgage limits for non-elevator projects should be set" do
      TestClass.new minimum_params.merge!('is_elevator_project'=>false)
      Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms.should == @nonelevator_stat_limits.zero_bedroom
      Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms.should == @nonelevator_stat_limits.one_bedroom
      Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms.should == @nonelevator_stat_limits.two_bedroom
      Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms.should == @nonelevator_stat_limits.three_bedroom
      Criterion4::StatutoryMortgageLimits.non_elevator_4_bedrooms.should == @nonelevator_stat_limits.four_bedroom
    end
  end
  
  describe "to_json" do
    
    context "minimum parameters supplied" do

      it "should set criterion 1 attributes as expected" do
        min_loan_in_json['criterion_1']['loan_request'].should == minimum_params['loan_request']
      end

      it "should set criterion 3 percent multiplier as expected" do
        expected = @fha_lr[minimum_params['affordability']]
        min_loan_in_json['criterion_3']['line_a']['percent_multiplier'].should == expected
      end

      it "should set criterion 4 attributes as expected" do
        min_loan_in_json['criterion_4']['line_b']['cost_not_attributable_to_dwelling_use'].should be nil
        params = minimum_params['spaceUtilization']['apartment']['unitMix']
        min_loan_in_json['criterion_4']['line_a']['number_of_no_bedroom_units']['units'].should == params['number_of_no_bedroom_units']
        min_loan_in_json['criterion_4']['line_a']['number_of_one_bedroom_units']['units'].should == params['number_of_one_bedroom_units']
        min_loan_in_json['criterion_4']['line_a']['number_of_two_bedroom_units']['units'].should == params['number_of_two_bedroom_units']
        min_loan_in_json['criterion_4']['line_a']['number_of_three_bedroom_units']['units'].should == params['number_of_three_bedroom_units']
        min_loan_in_json['criterion_4']['line_a']['number_of_four_or_more_bedroom_units']['units'].should == params['number_of_four_or_more_bedroom_units']
      end

      it "should set criterion 5" do
        params = minimum_params['loanParameters']
        min_loan_in_json['criterion_5']['line_a']['mortgage_interest_rate'].should be_within(0.005).of params['mortgage_interest_rate']
        min_loan_in_json['criterion_5']['line_b']['mortgage_insurance_premium_rate'].should be_within(0.005).of @mip.without_lihtc_annual
        min_loan_in_json['criterion_5']['line_e']['percent_multiplier'].should == @fha_lr[minimum_params['affordability']]
      end
    end
    
  end
  
  describe "errors_to_json" do
    
    before(:each) {@min_params = minimum_params}
    
    after(:each) do
      loan = TestClass.new @min_params
      loan.should_not be_valid
      errors = ActiveSupport::JSON.decode loan.errors_to_json
      # p "errors #{errors}"
      errors.size.should == @error_total
      @errors_arr.each {|ele| errors[ele.first].should == ele.last}
    end
      
    context "error source is api user input" do

      describe "affordability" do

        after(:each) do
          @error_total = 1
          @errors_arr = [['affordability', ['is not an API-supported value']]]
        end

        it "should be included when it is not a recognized string" do
          @min_params['affordability'] = "something invalid"
        end

        it "shoulde be included when it is not a string" do
          @min_params['affordability'] = true
        end

        it "should be included when it is absent" do
          @min_params['affordability'] = nil
        end
      end

      describe "metropolitan_area_waiver" do
        after(:each) do
          @error_total = 1
          @errors_arr = [['metropolitan_area_waiver', ['is not an API-supported value']]]
        end

        it "should be included when it is not a recognized string" do
          @min_params['metropolitan_area_waiver'] = "something invalid"
        end

        it "should be included when it is not a recognized value" do
          @min_params['metropolitan_area_waiver'] = true
        end

        it "should be included when it is absent" do
          @min_params['metropolitan_area_waiver'] = nil
        end
      end
      
      it "should include value_in_fee_simple" do
        @min_params['loanParameters']['value_in_fee_simple'] = -1
        @error_total = 1
        @errors_arr = [['value_in_fee_simple', ["must be greater than or equal to 0"]]]
      end

      it "should not report any error for criterion 5 effective income or opex when income attrs are error source" do
        @min_params['operatingIncome']['gross_residential_income'] = nil
        @min_params['operatingIncome']['gross_commercial_income'] = -1
        @min_params['operatingIncome']['commercial_occupancy_percent'] = nil
        @min_params['operatingIncome']['residential_occupancy_percent'] = nil
        @error_total = 4
        @errors_arr = [['gross_residential_income', ["is not a number"]]]
        @errors_arr << ['gross_commercial_income', ["must be greater than or equal to 0"]]
        @errors_arr << ['commercial_occupancy_percent', ["is not a number"]]
        @errors_arr << ['residential_occupancy_percent', ["is not a number"]]
      end

      it "should not report any error for criterion_5 operating expenses when opex as pct invalid" do
        @min_params['operatingExpense']['operating_expenses_is_percent_of_effective_gross_income'] = "invalid datum"
        @error_total = 1
        @errors_arr = [['operating_expenses_is_percent_of_effective_gross_income', ["must be one of true, false or nil"]]]
      end

      it "should report operating expense when opex number invalid" do
        @min_params['operatingExpense']['operating_expenses'] = nil
        @error_total = 1
        @errors_arr = [['operating_expenses', ["is not a number"]]]
      end

      it "should include apartment unit mix errors" do
        @min_params['spaceUtilization']['apartment']['unitMix']['number_of_no_bedroom_units'] = -1
        @min_params['spaceUtilization']['apartment']['unitMix']['number_of_one_bedroom_units'] = -1
        @min_params['spaceUtilization']['apartment']['unitMix']['number_of_two_bedroom_units'] = -1
        @min_params['spaceUtilization']['apartment']['unitMix']['number_of_three_bedroom_units'] = -1
        @min_params['spaceUtilization']['apartment']['unitMix']['number_of_four_or_more_bedroom_units'] = -1
        @error_total = 5
        common_error = ["must be greater than or equal to 0"]
        @errors_arr = [['number_of_no_bedroom_units', common_error]]
        @errors_arr << ['number_of_one_bedroom_units', common_error]
        @errors_arr << ['number_of_two_bedroom_units', common_error]
        @errors_arr << ['number_of_three_bedroom_units', common_error]
        @errors_arr << ['number_of_four_or_more_bedroom_units', common_error]
      end

      it "should include warranted_price_of_land" do
        @min_params['warranted_price_of_land'] = -1
        @error_total = 1
        @errors_arr = [['warranted_price_of_land', ["must be greater than or equal to 0"]]]
      end

      it "should include is_elevator_project" do
        @min_params['is_elevator_project'] = "invalid value"
        @error_total = 1
        @errors_arr = [['is_elevator_project', ["must be one of true, false or nil"]]]
      end

      it "should include space utilization parameters" do
        @min_params['spaceUtilization']['outdoor_residential_parking_square_feet'] = -1
        @min_params['spaceUtilization']['indoor_residential_parking_square_feet'] = -1
        @min_params['spaceUtilization']['gross_apartment_square_feet'] = nil
        @min_params['spaceUtilization']['outdoor_commercial_parking_square_feet'] = -1
        @min_params['spaceUtilization']['indoor_commercial_parking_square_feet'] = -1
        @min_params['spaceUtilization']['gross_other_square_feet'] = -1
        @min_params['spaceUtilization']['gross_commercial_square_feet'] = -1
        @min_params['spaceUtilization']['outdoor_parking_discount_percent'] = -1
        @error_total = 8
        @errors_arr = [['outdoor_residential_parking_square_feet', ["must be greater than or equal to 0"]]]
        @errors_arr << ['gross_apartment_square_feet', ['is not a number']]
        @errors_arr << ['indoor_residential_parking_square_feet', ['must be greater than or equal to 0']]
        @errors_arr << ['outdoor_commercial_parking_square_feet', ['must be greater than or equal to 0']]
        @errors_arr << ['indoor_commercial_parking_square_feet', ['must be greater than or equal to 0']]
        @errors_arr << ['gross_other_square_feet', ['must be greater than or equal to 0']]
        @errors_arr << ['gross_commercial_square_feet', ['must be greater than or equal to 0']]
        @errors_arr << ['outdoor_parking_discount_percent', ['must be greater than or equal to 0']]
      end

      it "should include mortgage_interest_rate" do
        @min_params['loanParameters']['mortgage_interest_rate'] = nil
        @error_total = 1
        @errors_arr = [['mortgage_interest_rate', ["is not a number"]]]
      end

      it "should include term_in_months" do
        @min_params['loanParameters']['term_in_months'] = nil
        @error_total = 1
        @errors_arr = [['term_in_months', ["is not a number"]]]
      end

      it "should include annual_special_assessment" do
        @min_params['loanParameters']['annual_special_assessment'] = -1
        @error_total = 1
        @errors_arr = [['annual_special_assessment', ["must be greater than or equal to 0"]]]
      end

      it "should include annual_replacement_reserve_per_unit" do
        @min_params['loanParameters']['annual_replacement_reserve_per_unit'] = 249.99
        @error_total = 1
        @errors_arr = [['annual_replacement_reserve_per_unit', ["must be greater than or equal to 250"]]]
      end
      
      it "should include annual_replacement_reserve_per_unit" do
        @min_params['loanParameters']['annual_replacement_reserve_per_unit'] = nil
        @error_total = 1
        @errors_arr = [['annual_replacement_reserve_per_unit', ["is not a number"]]]
      end
      
      it "should include legal_and_organizational" do
        @min_params['legal_and_organizational'] = -1
        @error_total = 1
        @errors_arr = [['legal_and_organizational', ["must be greater than or equal to 0"]]]
      end
      
      it "should include initial_deposit_to_replacement_reserve" do
        @min_params['initial_deposit_to_replacement_reserve'] = -1
        @error_total = 1
        @errors_arr = [['initial_deposit_to_replacement_reserve', ["must be greater than or equal to 0"]]]
      end
      
      it "should include third_party_reports" do
        @min_params['third_party_reports'] = -1
        @error_total = 1
        @errors_arr = [['third_party_reports', ["must be greater than or equal to 0"]]]
      end
      
      it "should include survey" do
        @min_params['survey'] = -1
        @error_total = 1
        @errors_arr = [['survey', ["must be greater than or equal to 0"]]]
      end
      
      it "should include other" do
        @min_params['other'] = -1
        @error_total = 1
        @errors_arr = [['other', ["must be greater than or equal to 0"]]]
      end
      
      it "should include major_movable_equipment" do
        @min_params['major_movable_equipment'] = -1
        @error_total = 1
        @errors_arr = [['major_movable_equipment', ["must be greater than or equal to 0"]]]
      end
      
      it "should include replacement_reserves_on_deposit" do
        @min_params['replacement_reserves_on_deposit'] = -1
        @error_total = 1
        @errors_arr = [['replacement_reserves_on_deposit', ["must be greater than or equal to 0"]]]
      end
      
      describe "title_and_recording_is_percent_of_loan" do
        it "should be included when it is not boolean or nil" do
          @min_params['title_and_recording_is_percent_of_loan'] = "some invalid value"
          @error_total = 1
          @errors_arr = [['title_and_recording_is_percent_of_loan', ["must be one of true, false or nil"]]]
        end
      end
      
      describe "title_and_recording" do
        
        it "should be included when less than 0" do
          @min_params['title_and_recording'] = -1
          @min_params['title_and_recording_is_percent_of_loan'] = nil
          @error_total = 1
          @errors_arr = [['title_and_recording', ["must be greater than or equal to 0"]]]
        end
        
        it "should be included when sent as percent and greater than 100" do
          @min_params['title_and_recording'] = 100.01
          @min_params['title_and_recording_is_percent_of_loan'] = true
          @error_total = 1
          msg = "must be less than or equal to 100"
          @errors_arr = [['title_and_recording', [msg]]]
        end
        
      end
      
      describe "financing_fee_is_percent_of_loan" do
        it "should be included when it is not boolean or nil" do
          @min_params['financing_fee_is_percent_of_loan'] = "some invalid value"
          @error_total = 1
          @errors_arr = [['financing_fee_is_percent_of_loan', ["must be one of true, false or nil"]]]
        end
      end
      
      describe "financing_fee" do
        
        it "should be included when less than 0" do
          @min_params['financing_fee'] = -1
          @min_params['financing_fee_is_percent_of_loan'] = nil
          @error_total = 1
          @errors_arr = [['financing_fee', ["must be greater than or equal to 0"]]]
        end
        
        it "should be included when sent as percent and greater than 100" do
          @min_params['financing_fee'] = 100.01
          @min_params['financing_fee_is_percent_of_loan'] = true
          @error_total = 1
          msg = "must be less than or equal to 100"
          @errors_arr = [['financing_fee', [msg]]]
        end
        
      end
    end
  end
  
end

describe "Sec 223f purchase" do
  
  before(:all) do
    @fha_lr = FactoryGirl.create(:fha_leverage_ratio_set)
    @mip = FactoryGirl.create(:sec207223f_mortgage_insurance_premium)
    @hcp = FactoryGirl.create(:high_cost_percentage, :city=>'New York', :state_abbreviation=>'NY')
    @initialization_set = FactoryGirl.create(:sec223f_multifamily_acquisition_parameters_initialization_set)
    @elevator_stat_limits = FactoryGirl.create(:sec223f_multifamily_elevator_stat_limit_set)
    @nonelevator_stat_limits = FactoryGirl.create(:sec223f_multifamily_non_elevator_stat_limit_set)
    @occupancy_limits = FactoryGirl.create(:sec223f_occupancy_constraint_set)
    class TestClass; include Sec223fPurchase; end
  end
  
  let(:minimum_params) {minimum_acquisition_params}
  let(:min_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(minimum_acquisition_params)).to_json)['loan']}
  
  it_behaves_like "a generic sec 223f"
  
  describe "valid?" do
    
    before(:each){@loan = TestClass.new minimum_params}
    
    it "should be false when no underlying sec 223f attribute" do
      @loan.should_receive(:sec223f_acquisition).and_return nil
      (@loan.valid?).should be false
    end
    
    it "should be true when underlying sec 223f is valid" do
      loan = double('loan', :valid? =>true)
      loan.should_receive(:tax_abatement)
      loan.should_receive(:lease)
      @loan.should_receive(:sec223f_acquisition).any_number_of_times.and_return loan
      (@loan.valid?).should be true
    end
    
    it "should be false when underlying sec 223f attribute is not valid" do
      loan = double('loan', :valid? =>false)
      loan.should_receive(:tax_abatement)
      loan.should_receive(:lease)
      @loan.should_receive(:sec223f_acquisition).any_number_of_times.and_return loan
      (@loan.valid?).should be false
    end
    
    it "should be false when lease is not valid" do
      loan = double('loan', :valid? =>true)
      lease = double('lease', :valid? =>false)
      loan.should_receive(:tax_abatement)
      loan.should_receive(:lease).any_number_of_times.and_return lease
      @loan.should_receive(:sec223f_acquisition).any_number_of_times.and_return loan
      (@loan.valid?).should be false
    end
    
    it "should be false when tax_abatement is not valid" do
      loan = double('loan', :valid? =>true)
      tax_abatement = double('tax_abatement', :valid? =>false)
      loan.should_receive(:tax_abatement).any_number_of_times.and_return tax_abatement
      loan.should_receive(:lease)
      @loan.should_receive(:sec223f_acquisition).any_number_of_times.and_return loan
      (@loan.valid?).should be false
    end
    
  end
  
  describe "errors_to_json" do
    
    before(:each) {@min_params = minimum_params}
    
    after(:each) do
      loan = TestClass.new @min_params
      loan.should_not be_valid
      errors = ActiveSupport::JSON.decode loan.errors_to_json
      # p "errors #{errors}"
      errors.size.should == @error_total
      @errors_arr.each {|ele| errors[ele.first].should == ele.last}
    end
    
    context "error source is api user input" do
      
      it "should include purchase price and value when latter not supplied and purchase price invalid" do
        @min_params['loanParameters']['purchase_price_of_project'] = -1
        @error_total = 2
        @errors_arr = [['value_in_fee_simple', ["must be greater than or equal to 0"]]]
        @errors_arr << ['purchase_price_of_project', ["must be greater than or equal to 0"]]
      end
      
      it "should include repairs_and_improvements" do
        @min_params['loanParameters']['repairs_and_improvements'] = -1
        @error_total = 1
        @errors_arr = [['repairs_and_improvements', ["must be greater than or equal to 0"]]]
      end
      
    end
    
  end
  
  describe "to_json" do
    
    context "maximum parameters supplied" do
      let(:maximum_params) {maximum_acquisition_params}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_acquisition_params)).to_json)['loan']}
      
      it "should set criterion 7" do
        params = maximum_params['loanParameters']
        crit_7 = max_loan_in_json['criterion_7']
        crit_7['line_a']['purchase_price_of_project'].should == params['purchase_price_of_project']
        crit_7['line_b']['repairs_and_improvements'].should == params['repairs_and_improvements']
        crit_7['line_c']['other_fees'].should be > 0
        crit_7['line_d']['loan_closing_charges'].should be > 0
        crit_7['line_f']['sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment'].should be > 0
        crit_7['line_h']['percent_multiplier'].should == @fha_lr[maximum_params['affordability']]
      end
    end
    
    context "when lease supplied" do
      
      let(:maximum_params) {maximum_acquisition_params_including_criterion_11_and_fixed_lease}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_params)).to_json)['loan']}
      
      it "should appear in criteria 3, 4, 5 and 11" do
        max_loan_in_json['criterion_11']['line_b3']['value_of_leased_fee'].should be > 0
        max_loan_in_json['criterion_3']['line_b_1']['value_of_leased_fee'].should be > 0
        crit_4_attr = max_loan_in_json['criterion_4']['line_f']['sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments']
        (crit_4_attr - maximum_params[:unpaid_balance_of_special_assessments]).should be > 0
        max_loan_in_json['criterion_5']['line_f']['annual_ground_rent'].should be > 0
      end
      
    end
    
    context "when tax_abatement (fixed with length shorted than loan term) supplied" do
      
      let(:maximum_params) {maximum_acquisition_params_including_criterion_11_and_short_fixed_tax_abatement}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_params)).to_json)['loan']}
      
      it "should appear in criteria 5" do
        max_loan_in_json['criterion_5']['line_i']['tax_abatement_present_value'].should be > 0
      end
      
    end
    
    context "maximum parameters supplied, including those requiring criterion 11" do
      let(:maximum_params) {maximum_acquisition_params_including_criterion_11_and_fixed_lease}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_params)).to_json)['loan']}
      
      it "should set criterion 11 with maximum expected params" do
        crit_11 = max_loan_in_json['criterion_11']
        grants_loans_gifts = maximum_params[:gifts].to_f + maximum_params[:grants].to_f + 
                             maximum_params[:private_loans].to_f + maximum_params[:public_loans].to_f
        crit_11['line_b1']['grants_loans_gifts'].should be_within(0.005).of grants_loans_gifts
        crit_11['line_b2']['tax_credits'].should be_within(0.005).of maximum_params[:tax_credits]
        expected = maximum_params[:excess_unusual_land_improvement]
        crit_11['line_b3']['value_of_leased_fee'].should be > 0
        crit_11['line_b4']['excess_unusual_land_improvement_cost'].should be_within(0.005).of(expected)
        expected = maximum_params[:cost_containment_mortgage_deduction]
        crit_11['line_b5']['cost_containment_mortgage_deductions'].should be_within(0.005).of(expected)
        expected = maximum_params[:unpaid_balance_of_special_assessments]
        crit_11['line_b6']['unpaid_balance_of_special_assessment'].should be_within(0.005).of(expected)
        crit_11['line_a']['project_cost'].should be > 0
        crit_11['line_c']['line_a_minus_line_b'].should be > 0
      end
    end
          
    context "minimum parameters supplied" do
      
      it "should set criterion 3 value to purchase price" do
        expected = minimum_params['loanParameters']['purchase_price_of_project']
        min_loan_in_json['criterion_3']['line_a']['value_in_fee_simple'].should == expected
      end

      it "should set criterion 7" do
        params = minimum_params['loanParameters']
        crit_7 = min_loan_in_json['criterion_7']
        crit_7['line_a']['purchase_price_of_project'].should == params['purchase_price_of_project']
        crit_7['line_d']['loan_closing_charges'].should be > 0
        crit_7['line_h']['percent_multiplier'].should == @fha_lr[minimum_params['affordability']]
      end
    end
    
    context "minimum parameters supplied, plus those requiring criterion 11" do
      it "should set criterion 11 with minimum expected params" do
        params = minimum_acquisition_params_including_for_criterion_11
        min_in_json = ActiveSupport::JSON.decode((TestClass.new(params)).to_json)['loan']
        params = minimum_acquisition_params_including_for_criterion_11
        crit_11 = min_in_json['criterion_11']
        grants_loans_gifts = params[:gifts].to_f + params[:grants].to_f + params[:private_loans].to_f +
                             params[:public_loans].to_f
        crit_11['line_b1']['grants_loans_gifts'].should be_within(0.005).of grants_loans_gifts
        crit_11['line_b2']['tax_credits'].should be_within(0.005).of params[:tax_credits]
        crit_11['line_a']['project_cost'].should be > 0
        crit_11['line_c']['line_a_minus_line_b'].should be > 0
      end
    end
    
  end
  
end

describe "Sec 223f refinance" do
  
  before(:all) do
    @fha_lr = FactoryGirl.create(:fha_leverage_ratio_set)
    @mip = FactoryGirl.create(:sec207223f_mortgage_insurance_premium)
    @hcp = FactoryGirl.create(:high_cost_percentage, :city=>'New York', :state_abbreviation=>'NY')
    @initialization_set = FactoryGirl.create(:sec223f_multifamily_acquisition_parameters_initialization_set)
    @elevator_stat_limits = FactoryGirl.create(:sec223f_multifamily_elevator_stat_limit_set)
    @nonelevator_stat_limits = FactoryGirl.create(:sec223f_multifamily_non_elevator_stat_limit_set)
    @occupancy_limits = FactoryGirl.create(:sec223f_occupancy_constraint_set)
    class TestClass; include Refinance; end
  end
  
  let(:minimum_params) {minimum_refinance_params}
  let(:min_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(minimum_refinance_params)).to_json)['loan']}
  
  it_behaves_like "a generic sec 223f"
  
  describe "valid?" do
    
    let(:loan){TestClass.new minimum_params}
    
    it "should be false when no underlying sec 223f attribute" do
      loan.should_receive(:sec223f_refinance).and_return nil
      (loan.valid?).should be false
    end
    
    it "should be true when underlying sec 223f is valid" do
      sec_223f = double('loan', :valid? =>true)
      sec_223f.should_receive(:tax_abatement)
      sec_223f.should_receive(:lease)
      loan.should_receive(:sec223f_refinance).any_number_of_times.and_return sec_223f
      (loan.valid?).should be true
    end
    
    it "should be false when underlying sec 223f attribute is not valid" do
      sec_223f = double('loan', :valid? =>false)
      sec_223f.should_receive(:tax_abatement)
      sec_223f.should_receive(:lease)
      loan.should_receive(:sec223f_refinance).any_number_of_times.and_return sec_223f
      (loan.valid?).should be false
    end
    
    it "should be false when lease is not valid" do
      sec_223f = double('loan', :valid? =>true)
      lease = double('lease', :valid? =>false)
      sec_223f.should_receive(:tax_abatement)
      sec_223f.should_receive(:lease).any_number_of_times.and_return lease
      loan.should_receive(:sec223f_refinance).any_number_of_times.and_return sec_223f
      (loan.valid?).should be false
    end
    
    it "should be false when tax_abatement is not valid" do
      sec_223f = double('loan', :valid? =>true)
      tax_abatement = double('tax_abatement', :valid? =>false)
      sec_223f.should_receive(:tax_abatement).any_number_of_times.and_return tax_abatement
      sec_223f.should_receive(:lease)
      loan.should_receive(:sec223f_refinance).any_number_of_times.and_return sec_223f
      (loan.valid?).should be false
    end
    
  end
  
  describe "to_json" do
    
    context "minimum parameters supplied" do
      it "should set criterion 3 value to value_in_fee_simple" do
        expected = minimum_params['value_in_fee_simple']
        min_loan_in_json['criterion_3']['line_a']['value_in_fee_simple'].should == expected
      end
    end
    
    context "maximum parameters supplied" do
      let(:maximum_params) {maximum_refinance_params}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_params)).to_json)['loan']}
      
      it "should set criterion 10" do
        crit_10 = max_loan_in_json['criterion_10']
        crit_10['line_a']['total_existing_indebtedness'].should == maximum_params[:existing_indebtedness]
        crit_10['line_b']['required_repairs'].should == maximum_params[:repairs]
        crit_10['line_c']['other_fees'].should be > 0
        crit_10['line_d']['loan_closing_charges'].should be > 0
        crit_10['line_f']['sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment'].should be > 0
        crit_10['line_h']['value'].should == maximum_params[:loanParameters][:value_in_fee_simple]
      end
    end
    
    context "when lease supplied" do
      
      let(:maximum_params) {maximum_refinance_params_including_criterion_11_and_fixed_lease}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_params)).to_json)['loan']}
      
      it "should appear in criteria 3, 4, 5 and 11" do
        max_loan_in_json['criterion_11']['line_b3']['value_of_leased_fee'].should be > 0
        max_loan_in_json['criterion_3']['line_b_1']['value_of_leased_fee'].should be > 0
        crit_4_attr = max_loan_in_json['criterion_4']['line_f']['sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments']
        (crit_4_attr - maximum_params[:unpaid_balance_of_special_assessments]).should be > 0
        max_loan_in_json['criterion_5']['line_f']['annual_ground_rent'].should be > 0
      end
    end
    
    context "when tax_abatement (fixed with length shorted than loan term) supplied" do
      
      let(:maximum_params) {maximum_refinance_params_including_criterion_11_and_short_fixed_tax_abatement}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_params)).to_json)['loan']}
      
      it "should appear in criteria 5" do
        max_loan_in_json['criterion_5']['line_i']['tax_abatement_present_value'].should be > 0
      end
    end
    
    context "maximum parameters supplied, including those requiring criterion 11" do
      let(:maximum_params) {maximum_refinance_params_including_criterion_11_and_fixed_lease}
      let(:max_loan_in_json) {ActiveSupport::JSON.decode((TestClass.new(maximum_params)).to_json)['loan']}
      
      it "should set criterion 11 with maximum expected params" do
        crit_11 = max_loan_in_json['criterion_11']
        grants_loans_gifts = maximum_params[:gifts].to_f + maximum_params[:grants].to_f + 
                             maximum_params[:private_loans].to_f + maximum_params[:public_loans].to_f
        crit_11['line_b1']['grants_loans_gifts'].should be_within(0.005).of grants_loans_gifts
        crit_11['line_b2']['tax_credits'].should be_within(0.005).of maximum_params[:tax_credits]
        expected = maximum_params[:excess_unusual_land_improvement]
        crit_11['line_b3']['value_of_leased_fee'].should be > 0
        crit_11['line_b4']['excess_unusual_land_improvement_cost'].should be_within(0.005).of(expected)
        expected = maximum_params[:cost_containment_mortgage_deduction]
        crit_11['line_b5']['cost_containment_mortgage_deductions'].should be_within(0.005).of(expected)
        expected = maximum_params[:unpaid_balance_of_special_assessments]
        crit_11['line_b6']['unpaid_balance_of_special_assessment'].should be_within(0.005).of(expected)
        crit_11['line_a']['project_cost'].should be > 0
        crit_11['line_c']['line_a_minus_line_b'].should be > 0
      end
    end
    
    context "minimum parameters supplied, plus those requiring criterion 11" do
      it "should set criterion 11 with minimum expected params" do
        params = minimum_refinance_params_including_for_criterion_11
        min_in_json = ActiveSupport::JSON.decode((TestClass.new(params)).to_json)['loan']
        params = minimum_acquisition_params_including_for_criterion_11
        crit_11 = min_in_json['criterion_11']
        grants_loans_gifts = params[:gifts].to_f + params[:grants].to_f + params[:private_loans].to_f +
                             params[:public_loans].to_f
        crit_11['line_b1']['grants_loans_gifts'].should be_within(0.005).of grants_loans_gifts
        crit_11['line_b2']['tax_credits'].should be_within(0.005).of params[:tax_credits]
        crit_11['line_a']['project_cost'].should be > 0
        crit_11['line_c']['line_a_minus_line_b'].should be > 0
      end
    end
  
  end
  
  describe "errors_to_json" do
    
    before(:each) {@min_params = minimum_params}
    
    after(:each) do
      loan = TestClass.new @min_params
      loan.should_not be_valid
      errors = ActiveSupport::JSON.decode loan.errors_to_json
      # p "errors #{errors}"
      errors.size.should == @error_total
      @errors_arr.each {|ele| errors[ele.first].should == ele.last}
    end
    
    context "error source is api user input" do
      
      it "should include value_in_fee_simple when invalid" do
        @min_params['loanParameters']['value_in_fee_simple'] = -1
        @error_total = 1
        @errors_arr = [['value_in_fee_simple', ["must be greater than or equal to 0"]]]
      end
      
      it "should include repairs" do
        @min_params['loanParameters']['repairs'] = -1
        @error_total = 1
        @errors_arr = [['repairs', ["must be greater than or equal to 0"]]]
      end
      
    end
    
  end
  
end