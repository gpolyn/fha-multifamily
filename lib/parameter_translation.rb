module ParameterTranslation
  
  extend ActiveSupport::Concern # all you need are module class methods and module instance methods for this to 
                                # offer include-type inclusion in dependent class!
  
  module InstanceMethods
    
    # could not get this to work with my sec223f_acquisition gem -- problem with criterion_7 param
    def initialize(input)
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
      criterion_4[:number_of_no_bedroom_units] = unit_mix[:zeroBedroomUnits]
      criterion_4[:number_of_one_bedroom_units] = unit_mix[:oneBedroomUnits]
      criterion_4[:number_of_two_bedroom_units] = unit_mix[:twoBedroomUnits]
      criterion_4[:number_of_three_bedroom_units] = unit_mix[:threeBedroomUnits]
      criterion_4[:number_of_four_or_more_bedroom_units] = unit_mix[:fourBedroomUnits]
      criterion_4[:warranted_price_of_land] = input[:warrantedPriceOfLand]
      criterion_4[:is_elevator_project] = input[:isElevatorProject]
      cna = Criterion4::CostNotAttributable.new(:project_value=>project_value)
      space = input[:spaceUtilization]
      cna.gross_apartment_square_feet = space[:apartment][:totalSquareFeet]
      cna.outdoor_residential_parking_square_feet = space[:residentialParkingIncomes][:totalOutdoorSquareFeet]
      cna.indoor_residential_parking_square_feet = space[:residentialParkingIncomes][:totalIndoorSquareFeet]
      cna.outdoor_commercial_parking_square_feet = space[:commercialParkingIncomes][:totalOutdoorSquareFeet]
      cna.indoor_commercial_parking_square_feet = space[:commercialParkingIncomes][:totalIndoorSquareFeet]
      cna.gross_other_square_feet = space[:otherResidential][:totalSquareFeet]
      cna.gross_commercial_square_feet = space[:commercial][:totalSquareFeet]
      cna.outdoor_parking_discount_percent = input[:loanParameters][:outdoorParkingDiscountPercent]
      criterion_4[:cost_not_attributable_to_dwelling_use] = cna.calculate
      # criterion 5
      criterion_5 = {}
      loan_params = input[:loanParameters]
      criterion_5[:mortgage_interest_rate] = loan_params[:mortgageInterestRate]
      criterion_5[:percent_multiplier] = leverage
      criterion_5[:mortgage_insurance_premium_rate] = mip.without_lihtc_annual
      criterion_5[:effective_income] = input[:operatingIncome][:effectiveGrossCommercialIncome] + 
                                       input[:operatingIncome][:effectiveGrossResidentialIncome]
      criterion_5[:operating_expenses] = if input[:operatingExpense][:totalIsPercentOfEffectiveGrossIncome]
        input[:operatingExpense][:total]/100 * criterion_5[:effective_income] 
      else
        input[:operatingExpense][:total]
      end
      criterion_5[:term_in_months] = input[:loanParameters][:termInMonths]
      criterion_5[:annual_special_assessment] = input[:loanParameters][:annualSpecialAssessment]
      annual_rfr = input[:loanParameters][:annualReplacementReservePerUnit] * unit_mix[:totalUnits]
      criterion_5[:annual_replacement_reserve] = annual_rfr
      # criterion 7
      params = input[:loanParameters]
      criterion_7 = {}
      criterion_7[:percent_multiplier] = leverage
      criterion_7[:purchase_price_of_project] = params[:purchasePrice]
      criterion_7[:repairs_and_improvements] = params[:repairsOrImprovements]
      criterion_7[:legal_and_organizational] = params[:legalAndOrganizational]
      criterion_7[:initial_deposit_to_replacement_reserve] = params[:initialDepositToReplacementReserve]
      criterion_7[:third_party_reports] = params[:thirdPartyReports]
      criterion_7[:survey] = params[:survey]
      criterion_7[:other] = params[:other]
      criterion_7[:major_movable_equipment] = params[:majorMovableEquipment]
      criterion_7[:replacement_reserves_on_deposit] = params[:replacementReservesOnDeposit]
      criterion_7[:first_year_mortgage_insurance_premium_rate] = mip.without_lihtc_initial
      criterion_7[:exam_fee_rate] = Sec223fMultifamilyAcquisitionParametersInitializationSet.last.exam_fee_rate
  
      if params[:financingFeeIsPercentOfLoan]
        criterion_7[:financing_fee_rate] = params[:financingFee]
      else
        criterion_7[:financing_fee] = params[:financingFee]
      end
  
      if params[:titleAndRecordingIsPercentOfLoan]
        criterion_7[:title_and_recording_rate] = params[:titleAndRecording]
      else
        criterion_7[:title_and_recording] = params[:titleAndRecording]
      end
  
      set_apartment_stat_limits input[:isElevatorProject]
      super(:criterion_3 => criterion_3, :criterion_4 => criterion_4, :loan_request => loan_request,
             :criterion_5 => criterion_5, :criterion_7 => criterion_7)
    end
  
    protected
  
    def set_apartment_stat_limits(has_elevator)
      if has_elevator
        elevator = Sec223fMultifamilyElevatorStatLimitSet.last
        Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms = elevator.zero_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms = elevator.one_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms = elevator.two_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms = elevator.three_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_4_plus_bedrooms = elevator.four_bedroom
      else
        non_elevator = Sec223fMultifamilyNonElevatorStatLimitSet.last
        Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = non_elevator.zero_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = non_elevator.one_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = non_elevator.two_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = non_elevator.three_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = non_elevator.four_bedroom
      end
    end
  end
  
  # module ClassMethods
    
    def self.convert_params_to_initialize_sec223f_acquisition(input)
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
      # p "criterion_5 hash #{criterion_5.to_s}"
  		# criterion 7
  		params = input[:loanParameters]
  		criterion_7 = {}
  		criterion_7[:percent_multiplier] = leverage
  		criterion_7[:purchase_price_of_project] = params[:purchasePrice]
  		criterion_7[:repairs_and_improvements] = params[:repairsOrImprovements]
  		criterion_7[:legal_and_organizational] = params[:legalAndOrganizational]
  		criterion_7[:initial_deposit_to_replacement_reserve] = params[:initialDepositToReplacementReserve]
      criterion_7[:third_party_reports] = params[:thirdPartyReports]
      criterion_7[:survey] = params[:survey]
      criterion_7[:other] = params[:other]
      criterion_7[:major_movable_equipment] = params[:majorMovableEquipment]
      criterion_7[:replacement_reserves_on_deposit] = params[:replacementReservesOnDeposit]
      criterion_7[:first_year_mortgage_insurance_premium_rate] = mip.without_lihtc_initial
      criterion_7[:exam_fee_rate] = Sec223fMultifamilyAcquisitionParametersInitializationSet.last.exam_fee_rate

      if params[:financingFeeIsPercentOfLoan]
        criterion_7[:financing_fee_rate] = params[:financingFee]
      else
        criterion_7[:financing_fee_in_dollars] = params[:financingFee]
      end

      if params[:titleAndRecordingIsPercentOfLoan]
        criterion_7[:title_and_recording_rate] = params[:titleAndRecording]
      else
        criterion_7[:title_and_recording_in_dollars] = params[:titleAndRecording]
      end

      set_apartment_stat_limits input[:isElevatorProject]
      {:criterion_3 => criterion_3, :criterion_4 => criterion_4, :loan_request => loan_request,
       :criterion_5 => criterion_5, :criterion_7 => criterion_7}
    end

    def self.set_apartment_stat_limits(has_elevator)
      if has_elevator
        elevator = Sec223fMultifamilyElevatorStatLimitSet.last
        Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms = elevator.zero_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms = elevator.one_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms = elevator.two_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms = elevator.three_bedroom
        Criterion4::StatutoryMortgageLimits.elevator_4_plus_bedrooms = elevator.four_bedroom
      else
        non_elevator = Sec223fMultifamilyNonElevatorStatLimitSet.last
        Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = non_elevator.zero_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = non_elevator.one_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = non_elevator.two_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = non_elevator.three_bedroom
        Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = non_elevator.four_bedroom
      end
    end
  
end