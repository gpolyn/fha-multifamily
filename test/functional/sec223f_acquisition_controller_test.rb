# Author:: Gallagher Polyn  (mailto:gallagher.polyn@gmail.com)
# Copyright:: Copyright (c) 2011 Gallagher Polyn

require 'test_helper'

class Sec223fAcquisitionControllerTest < ActionController::TestCase
  
  test "should generate path and recognize route for GET loan" do
    assert_routing({:path => "/sec_223f_acquisition", :method => :post},{:action => "loan", :controller=>"sec223f_acquisition"})
  end
  
  test "GET loan should assign loan" do
    # Sec223fAcquisition::Sec223fAcquisition.any_instance.stubs(:new).returns(Object.new)
    # Sec223fAcquisition::Sec223fAcquisition.any_instance.stubs(:valid?).returns(true)
    # p "json params #{ActiveSupport::JSON.encode(minimum_valid_json_params)}" #minimum_valid_json_params
    # post :loan, ActiveSupport::JSON.encode(minimum_valid_json_params), "CONTENT_TYPE" => 'application/json' #, :format=> :json
    # assert_equal({}, minimum_valid_json_params)
    # assert_response :success
    request = 4_000_000
    post :loan, {:loan_request=>request, :format => :json}
    # p "request #{@request.body}"
    assert_not_nil assigns(:loan)
  end
  
  private
  
  def minimum_valid_json_params
    criterion_3_attrs = {:value_in_fee_simple => 1_000_000, :percent_multiplier => 85, 
                          :value_of_leased_fee => 5_000, 
                          :excess_unusual_land_improvement => 4_000,
                          :cost_containment_mortgage_deduction => 5_000, 
                          :unpaid_balance_of_special_assessment => 10_000}
    criterion_5_attrs = {:mortgage_interest_rate=>5.5, :percent_multiplier=>85, 
                          :mortgage_insurance_premium_rate=>0.45, :effective_income=>1_000_000, 
                          :operating_expenses=>500_000, :annual_replacement_reserve=>10_000, 
                          :annual_tax_abatement=>40_000, :annual_ground_rent=> 10_000,
                          :annual_special_assessment => 10_000, :term_in_months => 420,
                          :tax_abatement_present_value=> 10_000}
    loan_request = 10_000_000
    criterion_4_attrs = {:high_cost_percentage => 270, :is_elevator_project => true, 
                          :number_of_no_bedroom_units => 10, 
                          :number_of_one_bedroom_units => 11, :number_of_two_bedroom_units => 12, 
                          :number_of_three_bedroom_units => 13, :number_of_four_or_more_bedroom_units => 14,
                          :cost_not_attributable_to_dwelling_use => 4_000_000, :warranted_price_of_land => 1_000_000,
                          :total_number_of_spaces => 20, :value_of_leased_fee => 1_000_000, 
                          :unpaid_balance_of_special_assessments => 100_000}
    criterion_7_attrs = {:percent_multiplier => 80, :purchase_price_of_project => 12_300_000, 
                          :repairs_and_improvements => 75_000, :legal_and_organizational => 15_000,
                          :initial_deposit_to_replacement_reserve => 30_000,
                          :third_party_reports => 15_000, :survey => 5_000, :other => 10_000,
                          :major_movable_equipment => 100_000, :replacement_reserves_on_deposit => 45_000,
                          :first_year_mortgage_insurance_premium_rate => 1, :discounts_rate => 1,
                          :mortgagable_bond_costs_rate => 0.75, :permanent_placement_rate => 0.5,
                          :exam_fee_rate => 0.3}
    {:criterion_3 => criterion_3_attrs, :criterion_4 => criterion_4_attrs, :loan_request => loan_request,
     :criterion_5 => criterion_5_attrs, :criterion_7 => criterion_7_attrs}
  end
  
  # def minimum_valid_json_params_2
  #   criterion_3_attrs = {"value_in_fee_simple": 1000000, "percent_multiplier": 85, 
  #                        "value_of_leased_fee": 5000, 
  #                        "excess_unusual_land_improvement": 4000,
  #                        "cost_containment_mortgage_deduction": 5000, 
  #                         "unpaid_balance_of_special_assessment": 10000}
  #   criterion_5_attrs = {"mortgage_interest_rate": 5.5, "percent_multiplier": 85, 
  #                         "mortgage_insurance_premium_rate": 0.45, "effective_income": 1000000, 
  #                         "operating_expenses":500000, "annual_replacement_reserve": 10000, 
  #                         "annual_tax_abatement": 40000, "annual_ground_rent": 10000,
  #                         "annual_special_assessment": 10000, "term_in_months": 420,
  #                         "tax_abatement_present_value": 10000}
  #   loan_request = 10000000
  #   criterion_4_attrs = {"high_cost_percentage": 270, "is_elevator_project": true, 
  #                        "number_of_no_bedroom_units": 10, 
  #                        "number_of_one_bedroom_units": 11, "number_of_two_bedroom_units": 12, 
  #                        "number_of_three_bedroom_units": 13, "number_of_four_or_more_bedroom_units": 14,
  #                        "cost_not_attributable_to_dwelling_use": 4000000, "warranted_price_of_land": 1000000,
  #                        "total_number_of_spaces": 20, "value_of_leased_fee": 1000000, 
  #                        "unpaid_balance_of_special_assessments": 100000}
  #   criterion_7_attrs = {"percent_multiplier": 80, "purchase_price_of_project": 12300000, 
  #                         "repairs_and_improvements": 75000, "legal_and_organizational": 15000,
  #                         "initial_deposit_to_replacement_reserve": 30000,
  #                         "third_party_reports": 15000, "survey": 5000, "other": 10000,
  #                         "major_movable_equipment": 100000, "replacement_reserves_on_deposit": 45000,
  #                         "first_year_mortgage_insurance_premium_rate": 1, "discounts_rate": 1,
  #                         "mortgagable_bond_costs_rate": 0.75, "permanent_placement_rate": 0.5,
  #                         "exam_fee_rate": 0.3}
  #   {"criterion_3": criterion_3_attrs, "criterion_4": criterion_4_attrs, "loan_request": loan_request,
  #    "criterion_5": criterion_5_attrs, "criterion_7": criterion_7_attrs}
  # end
  
end