FactoryGirl.define do
  
  factory :fha_leverage_ratio_set do
    market 83.3
    subsidized 87
    affordable 85
    cash_out_refinance 80
  end
  
  factory :sec223f_occupancy_constraint_set do
    minimum_residential_occupancy_percent 85
    maximum_commercial_occupancy_percent 80
    maximum_market_rate_residential_occupancy_percent 93
    maximum_affordable_residential_occupancy_percent 95
  end

  factory :sec207223f_mortgage_insurance_premium do
    without_lihtc_annual 0.45
    with_lihtc_annual 0.45
    without_lihtc_initial 1 
    with_lihtc_initial 1
  end
  
  factory :high_cost_percentage do
    city 'New York'
    state_abbreviation 'NY'
    value 270
    regional_office_city 'New York'
    regional_office_state_abbreviation 'NY'
    cbsa_code '12345' 
  end
                                                    
  factory :sec223f_multifamily_acquisition_parameters_initialization_set do
    mortgage_interest_rate 4.5 
    financing_fee_as_percent_of_loan 2.5 
    financing_fee_in_dollars 100_000
    legal_and_organizational 15_000
    title_and_recording_as_percent_of_loan 0.005
    exam_fee_rate 0.3
    third_party_reports 15_00
    survey 8_500
    annual_replacement_reserve_per_unit 250
  end
  
  factory :sec223f_multifamily_elevator_stat_limit_set do
    zero_bedroom 53171
    one_bedroom 59551
    two_bedroom 73022
    three_bedroom 91546
    four_bedroom 103410
  end
  
  factory :sec223f_multifamily_non_elevator_stat_limit_set do
    zero_bedroom 46079
    one_bedroom 51043
    two_bedroom 60969
    three_bedroom 75149
    four_bedroom 85077
  end
  
end