module Helpers
  
  def maximum_acquisition_params
    params = {}
    params['affordability'] = 'affordable'
    params['loanParameters'] = {}
    params['loanParameters']['value_in_fee_simple'] = 10_000_000
    params['loanParameters']['purchase_price_of_project'] = 9_750_000
    params['loan_request'] = 8_750_000
    params['metropolitan_area_waiver'] = 'New York, NY'
    
    mix = {}
    params['spaceUtilization'] = {'apartment' => {'unitMix'=> mix}}
    mix['number_of_no_bedroom_units'] = 10
    mix['number_of_one_bedroom_units'] = 15
    mix['number_of_two_bedroom_units'] = 20
    mix['number_of_three_bedroom_units'] = 25
    mix['number_of_four_or_more_bedroom_units'] = 30
    params['warranted_price_of_land'] = 100_000
    params['is_elevator_project'] = true
    
    params['spaceUtilization']['gross_apartment_square_feet'] = 20_000
    params['spaceUtilization']['outdoor_residential_parking_square_feet'] = 10_000
    params['spaceUtilization']['indoor_residential_parking_square_feet'] = 20_000
    params['spaceUtilization']['outdoor_commercial_parking_square_feet'] = 15_000
    params['spaceUtilization']['indoor_commercial_parking_square_feet'] = 15_000
    params['spaceUtilization']['outdoor_parking_discount_percent'] = 50
    params['spaceUtilization']['gross_other_square_feet'] = 4_000
    params['spaceUtilization']['gross_commercial_square_feet'] = 10_000
    
    params['loanParameters']['mortgage_interest_rate'] = 4.5
    params['residentialIncome'] = {'gross_residential_income' =>1000000, 'residential_occupancy_percent'=>93}
    params['commercialIncome'] = {'gross_commercial_income' =>1000000, 'commercial_occupancy_percent'=>80}
    params['operatingExpense'] = {'operating_expenses_is_percent_of_effective_gross_income'=>true, 'operating_expenses'=>40}
    params['loanParameters']['term_in_months'] = 420
		params['loanParameters']['annual_special_assessment'] = 100000
		params['loanParameters']['annual_replacement_reserve_per_unit'] = 250
		
		params['loanParameters']['repairs_and_improvements'] = 100000
		params['loanParameters']['legal_and_organizational'] = 10000
		params['loanParameters']['initial_deposit_to_replacement_reserve'] = 100000
		params['loanParameters']['third_party_reports'] = 15000
		params['loanParameters']['survey'] = 7000
		params['loanParameters']['other'] = 1000
    params['loanParameters']['major_movable_equipment'] = 200000
    params['loanParameters']['replacement_reserve_on_deposit'] = 56000
		
		params['loanParameters']['financing_fee_is_percent_of_loan'] = true
		params['loanParameters']['financing_fee'] = 2
    params['loanParameters']['title_and_recording_is_percent_of_loan'] = true
    params['loanParameters']['title_and_recording'] = 0.15
    params
  end
  
  def minimum_acquisition_params
    params = {}
    params['affordability'] = 'affordable'
    params['loanParameters'] = {}
    params['loanParameters']['annual_replacement_reserve_per_unit'] = 250
    params['loanParameters']['purchase_price_of_project'] = 9_750_000
    params['loan_request'] = 8_750_000
    params['metropolitan_area_waiver'] = 'New York, NY'
    
    mix = {}
    params['spaceUtilization'] = {'apartment' => {'unitMix'=> mix}}
    mix['number_of_two_bedroom_units'] = 20
    params['is_elevator_project'] = true
    
    params['loanParameters']['mortgage_interest_rate'] = 4.5
    params['operatingIncome'] = {'gross_residential_income' =>1000000, 'residential_occupancy_percent'=>93}
    params['operatingExpense'] = {'operating_expenses_is_percent_of_effective_gross_income'=>true, 'operating_expenses'=>40}
      params['loanParameters']['term_in_months'] = 420
    params
  end
  
  def minimum_refinance_params
    params = {}
    params['value_in_fee_simple'] = 9_750_000
    params['affordability'] = 'affordable'
    params['loanParameters'] = {}
    params['loanParameters']['annual_replacement_reserve_per_unit'] = 250
    params['loanParameters']['existing_indebtedness'] = 5_000_000
    params['loan_request'] = 2_000_000
    params['metropolitan_area_waiver'] = 'New York, NY'
    
    mix = {}
    params['spaceUtilization'] = {'apartment' => {'unitMix'=> mix}}
    mix['number_of_two_bedroom_units'] = 20
    params['is_elevator_project'] = true
    
    params['loanParameters']['mortgage_interest_rate'] = 4.5
    params['operatingIncome'] = {'gross_residential_income' =>1000000, 'residential_occupancy_percent'=>93}
    params['operatingExpense'] = {'operating_expenses_is_percent_of_effective_gross_income'=>true, 'operating_expenses'=>40}
      params['loanParameters']['term_in_months'] = 420
    params
  end
  
end