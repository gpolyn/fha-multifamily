module CommonSec223fApiBehavior
  
  include Sec223fCommonBehavior
  
  def initialize(args)
    input.recursive_symbolize_keys!
    
    leverage = FhaLeverageRatioSet.last[input[:affordability].to_sym]
    project_value = input[:loanParameters][:value] || input[:loanParameters][:purchasePrice]
    mip = Sec207223fMortgageInsurancePremium.last

    # criterion 1
    loan_request = input[:loan_request]
    # criterion 3
    criterion_3 = {:value_in_fee_simple => project_value, :percent_multiplier => leverage}
    # criterion 4
    criterion_4 = {}
    criterion_4[:high_cost_percentage] = HighCostPercentage.get_value input[:highCostPercentage]
    unit_mix = input[:spaceUtilization][:apartment][:unitMix]
    total_units = 0
    total_units += criterion_4[:number_of_no_bedroom_units] = unit_mix[:zeroBedroomUnits] if unit_mix[:zeroBedroomUnits]
    total_units += criterion_4[:number_of_one_bedroom_units] = unit_mix[:oneBedroomUnits] if unit_mix[:oneBedroomUnits]
    total_units += criterion_4[:number_of_two_bedroom_units] = unit_mix[:twoBedroomUnits] if unit_mix[:twoBedroomUnits]
    total_units += criterion_4[:number_of_three_bedroom_units] = unit_mix[:threeBedroomUnits] if unit_mix[:threeBedroomUnits]
    total_units += criterion_4[:number_of_four_or_more_bedroom_units] = unit_mix[:fourBedroomUnits] if unit_mix[:fourBedroomUnits]
    criterion_4[:warranted_price_of_land] = input[:warrantedPriceOfLand]
    criterion_4[:is_elevator_project] = input[:isElevatorProject]
    criterion_4[:outdoor_residential_parking_square_feet] = input[:spaceUtilization][:outdoor_residential_parking_square_feet]
    criterion_4[:indoor_residential_parking_square_feet] = input[:spaceUtilization][:indoor_residential_parking_square_feet]
    criterion_4[:outdoor_commercial_parking_square_feet] = input[:spaceUtilization][:outdoor_commercial_parking_square_feet]
    criterion_4[:indoor_commercial_parking_square_feet] = input[:spaceUtilization][:indoor_commercial_parking_square_feet]
    criterion_4[:outdoor_parking_discount_percent] = input[:spaceUtilization][:outdoor_parking_discount_percent]
    criterion_4[:gross_apartment_square_feet] = input[:spaceUtilization][:gross_apartment_square_feet]
    criterion_4[:gross_other_square_feet] = input[:spaceUtilization][:gross_other_square_feet]
    criterion_4[:gross_commercial_square_feet] = input[:spaceUtilization][:gross_commercial_square_feet]
    criterion_4[:project_value] = input[:spaceUtilization][:project_value]
                      
    # criterion 5
    criterion_5 = {}
    loan_params = input[:loanParameters]
    criterion_5[:mortgage_interest_rate] = loan_params[:mortgageInterestRate]
    criterion_5[:percent_multiplier] = leverage
    criterion_5[:mortgage_insurance_premium_rate] = mip.without_lihtc_annual
    criterion_5[:term_in_months] = input[:loanParameters][:termInMonths]
		criterion_5[:annual_special_assessment] = input[:loanParameters][:annualSpecialAssessment]
		
		if input[:loanParameters][:annualReplacementReservePerUnit]
		  annual_rfr = input[:loanParameters][:annualReplacementReservePerUnit] * total_units
		  criterion_5[:annual_replacement_reserve] = annual_rfr
	  end
	  
    criterion_5[:gross_residential_income] = input[:operatingIncome][:gross_residential_income]
    criterion_5[:gross_commercial_income] = input[:operatingIncome][:gross_commercial_income] 
    criterion_5[:commercial_occupancy_percent] = input[:operatingIncome][:commercial_occupancy_percent]
    criterion_5[:residential_occupancy_percent] = input[:operatingIncome][:residential_occupancy_percent]
    
    occupancy_limits = Sec223fOccupancyConstraintSet.last
    criterion_5[:minimum_residential_occupancy_percent] = occupancy_limits.minimum_residential_occupancy_percent
    criterion_5[:maximum_residential_occupancy_percent] = if input[:affordability] == 'market'
      occupancy_limits.maximum_market_rate_residential_occupancy_percent
    else
      occupancy_limits.maximum_affordable_residential_occupancy_percent
    end

    criterion_5[:maximum_commercial_occupancy_percent] = occupancy_limits.maximum_commercial_occupancy_percent
    criterion_5[:operating_expenses_is_percent_of_effective_gross_income] = input[:operatingExpense][:operating_expenses_is_percent_of_effective_gross_income]
    criterion_5[:operating_expenses] = input[:operatingExpense][:total]
    
    attrs = {:criterion_3 => criterion_3, :criterion_4 => criterion_4, 
             :criterion_5 => criterion_5, :loan_request => loan_request}
    super attrs
  end
  
end