require 'spec_helper'

describe ParameterTranslation do
  
  before(:all) do
    @maximum_params = maximum_params
    @fha_lr = FactoryGirl.create(:fha_leverage_ratio_set)
    @mip = FactoryGirl.create(:sec207223f_mortgage_insurance_premium)
    @hcp = FactoryGirl.create(:high_cost_percentage, :city=>'New York', :state_abbreviation=>'NY')
    @initialization_set = FactoryGirl.create(:sec223f_multifamily_acquisition_parameters_initialization_set)
    @elevator_stat_limits = FactoryGirl.create(:sec223f_multifamily_elevator_stat_limit_set)
    @nonelevator_stat_limits = FactoryGirl.create(:sec223f_multifamily_non_elevator_stat_limit_set)
    @occupancy_limits = FactoryGirl.create(:sec223f_occupancy_constraint_set)
  end
  
  it "should set the stat mortgage limits for elevator projects" do
    ParameterTranslation.convert_params_to_initialize_sec223f_acquisition @maximum_params
    Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms.should == @elevator_stat_limits.zero_bedroom
    Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms.should == @elevator_stat_limits.one_bedroom
    Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms.should == @elevator_stat_limits.two_bedroom
    Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms.should == @elevator_stat_limits.three_bedroom
    Criterion4::StatutoryMortgageLimits.elevator_4_bedrooms.should == @elevator_stat_limits.four_bedroom
  end
  
  it "should set the stat mortgage limits for non-elevator projects" do
    mod_params = @maximum_params.dup
    mod_params['isElevatorProject'] = false
    ParameterTranslation.convert_params_to_initialize_sec223f_acquisition mod_params
    Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms.should == @nonelevator_stat_limits.zero_bedroom
    Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms.should == @nonelevator_stat_limits.one_bedroom
    Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms.should == @nonelevator_stat_limits.two_bedroom
    Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms.should == @nonelevator_stat_limits.three_bedroom
    Criterion4::StatutoryMortgageLimits.non_elevator_4_bedrooms.should == @nonelevator_stat_limits.four_bedroom
  end
  
  context "all parameters supplied" do
    
    before(:each) do
      params = ParameterTranslation.convert_params_to_initialize_sec223f_acquisition maximum_params
      @loan = Sec223fAcquisition::Sec223fAcquisition.new params
      @my_params = maximum_params
    end
    
    it "should set criterion 1 attributes as expected" do
      @loan.loan_request.should == @my_params['loan_request']
    end
    
    it "should set criterion 3 attributes as expected" do
      @loan.criterion_3.value_in_fee_simple.should == @my_params['loanParameters']['value']
      @loan.criterion_3.percent_multiplier.should == @fha_lr[@my_params['affordability']]
    end
    
    it "should set criterion 4 attributes as expected" do
      @loan.criterion_4.cost_not_attributable_to_dwelling_use.should be > 0
      @loan.criterion_4.high_cost_percentage.should == @hcp.value
      @loan.criterion_4.warranted_price_of_land.should == @my_params['warrantedPriceOfLand']
      @loan.criterion_4.is_elevator_project.should == @my_params['isElevatorProject']
      params = @my_params['spaceUtilization']['apartment']['unitMix']
      @loan.criterion_4.number_of_no_bedroom_units.should == params['zeroBedroomUnits']
      @loan.criterion_4.number_of_one_bedroom_units.should == params['oneBedroomUnits']
      @loan.criterion_4.number_of_two_bedroom_units.should == params['twoBedroomUnits']
      @loan.criterion_4.number_of_three_bedroom_units.should == params['threeBedroomUnits']
      @loan.criterion_4.number_of_four_or_more_bedroom_units.should == params['fourBedroomUnits']
    end
    
    it "should set criterion 5" do
      params = @my_params['loanParameters']
      @loan.criterion_5.mortgage_interest_rate.should be_within(0.005).of params['mortgageInterestRate']
      @loan.criterion_5.percent_multiplier.should == @fha_lr[@my_params['affordability']]
      @loan.criterion_5.mortgage_insurance_premium_rate.should be_within(0.005).of @mip.without_lihtc_annual
      @loan.criterion_5.effective_income.should be > 0
      @loan.criterion_5.operating_expenses.should be > 0
      @loan.criterion_5.annual_replacement_reserve.should be > 0
      @loan.criterion_5.debt_service_constant.should be > 0
      @loan.criterion_5.annual_special_assessment.should == params['annualSpecialAssessment']
    end
    
    it "should set criterion 7" do
      params = @my_params['loanParameters']
      @loan.criterion_7.purchase_price_of_project.should == params['purchasePrice']
      @loan.criterion_7.repairs_and_improvements.should == params['repairsOrImprovements']
      @loan.criterion_7.percent_multiplier.should == @fha_lr[@my_params['affordability']]
      @loan.criterion_7.initial_deposit_to_replacement_reserve.should == params['initialDepositToReplacementReserve']
      @loan.criterion_7.financing_fee_rate.should be_within(0.005).of params['financingFee']
      @loan.criterion_7.legal_and_organizational.should == params['legalAndOrganizational']
      @loan.criterion_7.title_and_recording_rate.should be_within(0.005).of params['titleAndRecording']
      @loan.criterion_7.first_year_mortgage_insurance_premium_rate.should be_within(0.005).of @mip.without_lihtc_initial
      @loan.criterion_7.exam_fee_rate.should be_within(0.005).of @initialization_set.exam_fee_rate
    end
    
  end
  
  context "minimum parameters supplied" do
    before(:each) do
      params = ParameterTranslation.convert_params_to_initialize_sec223f_acquisition minimum_params
      @loan = Sec223fAcquisition::Sec223fAcquisition.new params
      @my_params_2 = minimum_params
    end
    
    it "should set criterion 1 attributes as expected" do
      @loan.loan_request.should == @my_params_2['loan_request']
    end
    
    it "should set criterion 3 value to purchase price" do
      @loan.criterion_3.value_in_fee_simple.should == @my_params_2['loanParameters']['purchasePrice']
    end
    
    it "should set criterion 3 percent multiplier as expected" do
      @loan.criterion_3.percent_multiplier.should == @fha_lr[@my_params_2['affordability']]
    end
    
    it "should set criterion 4 attributes as expected" do
      @loan.criterion_4.cost_not_attributable_to_dwelling_use.should be nil
      @loan.criterion_4.high_cost_percentage.should == @hcp.value
      @loan.criterion_4.is_elevator_project.should == @my_params_2['isElevatorProject']
      params = @my_params_2['spaceUtilization']['apartment']['unitMix']
      @loan.criterion_4.number_of_no_bedroom_units.should == params['zeroBedroomUnits']
      @loan.criterion_4.number_of_one_bedroom_units.should == params['oneBedroomUnits']
      @loan.criterion_4.number_of_two_bedroom_units.should == params['twoBedroomUnits']
      @loan.criterion_4.number_of_three_bedroom_units.should == params['threeBedroomUnits']
      @loan.criterion_4.number_of_four_or_more_bedroom_units.should == params['fourBedroomUnits']
    end
    
    it "should set criterion 5" do
      params = @my_params_2['loanParameters']
      @loan.criterion_5.mortgage_interest_rate.should be_within(0.005).of params['mortgageInterestRate']
      @loan.criterion_5.percent_multiplier.should == @fha_lr[@my_params_2['affordability']]
      @loan.criterion_5.mortgage_insurance_premium_rate.should be_within(0.005).of @mip.without_lihtc_annual
      @loan.criterion_5.effective_income.should be > 0
      @loan.criterion_5.operating_expenses.should be > 0
      @loan.criterion_5.annual_replacement_reserve.should be nil
      @loan.criterion_5.debt_service_constant.should be > 0
      @loan.criterion_5.annual_special_assessment.should be nil
    end
    
    it "should set criterion 7" do
      params = @my_params_2['loanParameters']
      @loan.criterion_7.purchase_price_of_project.should == params['purchasePrice']
      @loan.criterion_7.percent_multiplier.should == @fha_lr[@my_params_2['affordability']]
      @loan.criterion_7.first_year_mortgage_insurance_premium_rate.should be_within(0.005).of @mip.without_lihtc_initial
      @loan.criterion_7.exam_fee_rate.should be_within(0.005).of @initialization_set.exam_fee_rate
      @loan.criterion_7.repairs_and_improvements.should be nil
      @loan.criterion_7.initial_deposit_to_replacement_reserve.should be nil
      @loan.criterion_7.financing_fee_rate.should be nil
      @loan.criterion_7.legal_and_organizational.should be nil
      @loan.criterion_7.title_and_recording_rate.should be nil
    end
    
  end
  
  it "should properly set when opex is set as dollar amount" do
    mod_params = minimum_params.clone
    expected = 100_000
    mod_params['operatingExpense'] = {'totalIsPercentOfEffectiveGrossIncome'=>false, 'total'=>expected}
    params = ParameterTranslation.convert_params_to_initialize_sec223f_acquisition mod_params
    (Sec223fAcquisition::Sec223fAcquisition.new params).criterion_5.operating_expenses.should == expected
  end
  
  it "should properly set when financing fee is set as dollar amount" do
    mod_params = minimum_params.clone
    mod_params['loanParameters']['financingFeeIsPercentOfLoan'] = false
		mod_params['loanParameters']['financingFee'] = expected = 100_000
    params = ParameterTranslation.convert_params_to_initialize_sec223f_acquisition mod_params
    (Sec223fAcquisition::Sec223fAcquisition.new params).criterion_7.financing_fee_in_dollars.should == expected
  end
  
  it "should properly set when title and recording is set as dollar amount" do
    mod_params = minimum_params.clone
    mod_params['loanParameters']['titleAndRecordingIsPercentOfLoan'] = false
		mod_params['loanParameters']['titleAndRecording'] = expected = 5_000
    params = ParameterTranslation.convert_params_to_initialize_sec223f_acquisition mod_params
    (Sec223fAcquisition::Sec223fAcquisition.new params).criterion_7.title_and_recording_in_dollars.should == expected
  end
  
  # it "should..." do
  #   params = ParameterTranslation.convert_params_to_initialize_sec223f_acquisition minimum_params
  #   @loan = Sec223fAcquisition::Sec223fAcquisition.new params
  #   p "loan amount #{@loan.maximum_insurable_mortgage}"
  # end
  
  # it "should do something..." do
  #   class Sec223fAcquisition::Sec223fAcquisition; include ParameterTranslation; end
  #   obj = Sec223fAcquisition::Sec223fAcquisition.new maximum_params
  #   # obj = SomeClass.new maximum_params
  # end
  
  private
  
  def minimum_params
    params = {}
    params['affordability'] = 'affordable'
    params['loanParameters'] = {}
    params['loanParameters']['purchasePrice'] = 9_750_000
    params['loan_request'] = 8_750_000
    params['highCostPercentage'] = 'New York, NY'
    
    mix = {}
    params['spaceUtilization'] = {'apartment' => {'unitMix'=> mix}}
    mix['twoBedroomUnits'] = 20
    params['isElevatorProject'] = true
    
    params['loanParameters']['mortgageInterestRate'] = 4.5
    params['operatingIncome'] = {'gross_residential_income' =>1000000, 'residential_occupancy_percent'=>93}
    params['operatingExpense'] = {'operating_expenses_is_percent_of_effective_gross_income'=>true, 'total'=>40}
		params['loanParameters']['termInMonths'] = 420
    params
  end
  
  def maximum_params
    params = {}
    params['affordability'] = 'affordable'
    params['loanParameters'] = {}
    params['loanParameters']['value'] = 10_000_000
    params['loanParameters']['purchasePrice'] = 9_750_000
    params['loan_request'] = 8_750_000
    params['highCostPercentage'] = 'New York, NY'
    
    mix = {'totalUnits'=>100}
    params['spaceUtilization'] = {'apartment' => {'unitMix'=> mix}}
    mix['zeroBedroomUnits'] = 10
    mix['oneBedroomUnits'] = 15
    mix['twoBedroomUnits'] = 20
    mix['threeBedroomUnits'] = 25
    mix['fourBedroomUnits'] = 30
    params['warrantedPriceOfLand'] = 100000
    params['isElevatorProject'] = true
    
    params['spaceUtilization']['gross_apartment_square_feet'] = 20_000
    params['spaceUtilization']['outdoor_residential_parking_square_feet'] = 10_000
    params['spaceUtilization']['indoor_residential_parking_square_feet'] = 20_000
    params['spaceUtilization']['outdoor_commercial_parking_square_feet'] = 15_000
    params['spaceUtilization']['indoor_commercial_parking_square_feet'] = 15_000
    params['spaceUtilization']['outdoor_parking_discount_percent'] = 50
    params['spaceUtilization']['gross_other_square_feet'] = 4_000
    params['spaceUtilization']['gross_commercial_square_feet'] = 10_000
    params['spaceUtilization']['project_value'] = params['loanParameters']['value']
    
    params['loanParameters']['mortgageInterestRate'] = 4.5
    incomes = {'gross_residential_income'=>100000, 'residential_occupancy_percent'=>90}
    params['operatingIncome'] = incomes
    params['operatingExpense'] = {'operating_expenses_is_percent_of_effective_gross_income'=>true, 'total'=>40}
		params['loanParameters']['termInMonths'] = 420
		params['loanParameters']['annualSpecialAssessment'] = 100000
		params['loanParameters']['annualReplacementReservePerUnit'] = 250
		
		params['loanParameters']['repairsOrImprovements'] = 100000
		params['loanParameters']['legalAndOrganizational'] = 10000
		params['loanParameters']['initialDepositToReplacementReserve'] = 100000
		params['loanParameters']['thirdPartyReports'] = 15000
		params['loanParameters']['survey'] = 7000
		params['loanParameters']['other'] = 1000
    params['loanParameters']['majorMovableEquipment'] = 200000
    params['loanParameters']['replacementReservesOnDeposit'] = 56000
		
		params['loanParameters']['financingFeeIsPercentOfLoan'] = true
		params['loanParameters']['financingFee'] = 2
    params['loanParameters']['titleAndRecordingIsPercentOfLoan'] = true
    params['loanParameters']['titleAndRecording'] = 0.15
    params
  end
  
end