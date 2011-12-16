module Sec223fPurchase
  
  def initialize(input={})
    input.recursive_symbolize_keys!
    flatter_hash = input.convert_to_first_level
    
    leverage = nil
    
    if flatter_hash[:affordability]
      lrs = FhaLeverageRatioSet.last
      
      begin
        flatter_hash[:percent_multiplier] = leverage = if lrs[flatter_hash[:affordability].to_sym].nil?
          self.affordability_is_in_error = true
          nil
        else
          lrs[input[:affordability].to_sym].to_f
        end
      rescue
        self.affordability_is_in_error = true
      end
    else
      flatter_hash[:percent_multiplier] = leverage = nil
      self.affordability_is_in_error = true
    end
    
    # check this into sec 223f acquisition?
    flatter_hash[:project_value] = project_value = flatter_hash[:value_in_fee_simple] || flatter_hash[:purchase_price_of_project]
    mip = Sec207223fMortgageInsurancePremium.last

    loan_request = flatter_hash[:loan_request]  # criterion 1

    criterion_3 = {:value_in_fee_simple => project_value, :percent_multiplier => leverage}
    
    [:excess_unusual_land_improvement, :cost_containment_mortgage_deduction,
     :unpaid_balance_of_special_assessments].each {|val| criterion_3[val] = flatter_hash[val] }
    
    criterion_4 = {}
    
    begin
      if flatter_hash[:metropolitan_area_waiver]
        hcp = HighCostPercentage.get_value flatter_hash[:metropolitan_area_waiver]

        criterion_4[:high_cost_percentage] = unless hcp
          self.metropolitan_area_is_in_error = true
          nil
        else
          hcp
        end
      else
        self.metropolitan_area_is_in_error = true
      end
    rescue
      self.metropolitan_area_is_in_error = true
    end
    
    [:number_of_no_bedroom_units, :number_of_one_bedroom_units, :number_of_two_bedroom_units, 
     :number_of_three_bedroom_units, :number_of_four_or_more_bedroom_units, :project_value,
     :warranted_price_of_land, :is_elevator_project, :outdoor_residential_parking_square_feet,
     :indoor_residential_parking_square_feet, :outdoor_commercial_parking_square_feet,
     :indoor_commercial_parking_square_feet, :outdoor_parking_discount_percent,
     :unpaid_balance_of_special_assessments,
     :gross_apartment_square_feet, :gross_other_square_feet, :percent_multiplier,
     :gross_commercial_square_feet].each {|val| criterion_4[val] = flatter_hash[val] }
    
    # criterion 5
    criterion_5 = {}
    criterion_5[:mortgage_insurance_premium_rate] = mip.without_lihtc_annual.to_f
    occupancy_limits = Sec223fOccupancyConstraintSet.last
    criterion_5[:minimum_residential_occupancy_percent] = occupancy_limits.minimum_residential_occupancy_percent
    criterion_5[:maximum_commercial_occupancy_percent] = occupancy_limits.maximum_commercial_occupancy_percent
    criterion_5[:maximum_residential_occupancy_percent] = if flatter_hash[:affordability] == 'market'
      occupancy_limits.maximum_market_rate_residential_occupancy_percent
    else
      occupancy_limits.maximum_affordable_residential_occupancy_percent
    end
    
    [:mortgage_interest_rate, :percent_multiplier, :term_in_months, :annual_special_assessment,
     :gross_residential_income, :gross_commercial_income, :commercial_occupancy_percent, 
     :operating_expenses_is_percent_of_effective_gross_income, :operating_expenses,
     :residential_occupancy_percent].each {|val| criterion_5[val] = flatter_hash[val]}
    # p "criterion 5 attrs #{criterion_5.to_json}"
		# criterion 7
    criterion_7 = {}
    [:percent_multiplier, :purchase_price_of_project, :repairs_and_improvements, :survey, :other,
     :title_and_recording_is_percent_of_loan, :title_and_recording, :financing_fee_is_percent_of_loan,
     :financing_fee, :legal_and_organizational, :initial_deposit_to_replacement_reserve, :third_party_reports,
     :major_movable_equipment, :replacement_reserves_on_deposit].each {|val| criterion_7[val] = flatter_hash[val]}
    
    criterion_7[:first_year_mortgage_insurance_premium_rate] = mip.without_lihtc_initial
    criterion_7[:exam_fee_rate] = Sec223fMultifamilyAcquisitionParametersInitializationSet.last.exam_fee_rate

    set_apartment_stat_limits flatter_hash[:is_elevator_project]

    attrs = {:criterion_3 => criterion_3, :criterion_4 => criterion_4, :criterion_5 => criterion_5,
             :loan_request => loan_request, :criterion_7=>criterion_7,
             :minimum_annual_replacement_reserve_per_unit => 250, # maybe add to initialization domain, later
             :annual_replacement_reserve_per_unit => flatter_hash[:annual_replacement_reserve_per_unit]}
    self.sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new attrs
  end
  
  def to_json
    sec223f_acquisition.to_json
  end
  
  def valid?
    return false unless sec223f_acquisition
    sec223f_acquisition.valid? && !affordability_is_in_error && !metropolitan_area_is_in_error
  end
  
  def errors_to_json
    errors = sec223f_acquisition.errors_as_json
    
    unless sec223f_acquisition.errors[:operating_expenses] && !sec223f_acquisition.errors[:operating_expenses].empty?
      errors.delete(:operating_expenses)
    end
    
    if errors[:mortgage_interest_rate] || errors[:term_in_months]
      errors.delete(:debt_service_constant)
    end
    
    errors.delete(:project_value) if errors[:value_in_fee_simple]
    
    if affordability_is_in_error
      errors[:affordability] = ['is not an API-supported value']
      errors.delete(:percent_multiplier)
    end
    
    if metropolitan_area_is_in_error
      errors[:metropolitan_area_waiver] = ['is not an API-supported value']
      errors.delete(:high_cost_percentage)
    end
    
    errors.delete(:effective_income)
    errors.to_json
  end
  
  protected
  
  attr_accessor :sec223f_acquisition, :affordability_is_in_error, :metropolitan_area_is_in_error
  
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
  
  private
  
  def true_false_or_nil?(val)
    val == true || val == false || val == nil
  end
end