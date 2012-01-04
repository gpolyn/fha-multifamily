require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "Sec223fAcquisition" do
  
  before(:each) do
    @criterion_3_attrs = {:value_in_fee_simple => 1_000_000, :percent_multiplier => 85, 
                          :value_of_leased_fee => 5_000, 
                          :excess_unusual_land_improvement => 4_000,
                          :cost_containment_mortgage_deduction => 5_000, 
                          :unpaid_balance_of_special_assessments => 10_000}
    @criterion_5_attrs = {:mortgage_interest_rate=>5.5, :percent_multiplier=>85, 
                          :mortgage_insurance_premium_rate=>0.45,
                          :operating_expenses=>500_000, :annual_replacement_reserve=>10_000, 
                          :annual_ground_rent=> 10_000,
                          :annual_special_assessment => 10_000, :term_in_months => 420,
                          :tax_abatement_present_value=> 10_000,:gross_residential_income=>1_000_000,
                           :residential_occupancy_percent=>93, :minimum_residential_occupancy_percent=>85,
                           :maximum_residential_occupancy_percent=>95}
    @loan_request = 10_000_000
    @criterion_4_attrs = {:high_cost_percentage => 270, :is_elevator_project => true, 
                          :number_of_no_bedroom_units => 10, :percent_multiplier=>85,
                          :number_of_one_bedroom_units => 11, :number_of_two_bedroom_units => 12, 
                          :number_of_three_bedroom_units => 13, :number_of_four_or_more_bedroom_units => 14,
                          :cost_not_attributable_to_dwelling_use => 4_000_000, :warranted_price_of_land => 1_000_000,
                          :value_of_leased_fee => 1_000_000, 
                          :unpaid_balance_of_special_assessments => 100_000}
    @criterion_7_attrs = {:percent_multiplier => 80, :purchase_price_of_project => 12_300_000, 
                          :repairs_and_improvements => 75_000, :legal_and_organizational => 15_000,
                          :initial_deposit_to_replacement_reserve => 30_000,
                          :third_party_reports => 15_000, :survey => 5_000, :other => 10_000,
                          :major_movable_equipment => 100_000, :replacement_reserves_on_deposit => 45_000,
                          :first_year_mortgage_insurance_premium_rate => 1, :discounts_rate => 1,
                          :mortgagable_bond_costs_rate => 0.75, :permanent_placement_rate => 0.5,
                          :exam_fee_rate => 0.3}
    @criterion_11_attrs = @criterion_7_attrs.dup.merge(:value_in_fee_simple=>@criterion_3_attrs[:value_in_fee_simple])
    @initialization_attrs = {:criterion_3 => @criterion_3_attrs, :criterion_4 => @criterion_4_attrs, 
                             :loan_request => @loan_request,
                             :criterion_5 => @criterion_5_attrs, :criterion_7 => @criterion_7_attrs}
    @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
  end

  specify {@sec223f_acquisition.should be_valid}
  
  it_behaves_like "Hud92013::Attachments::DevelopmentCosts" do
    let(:host){@sec223f_acquisition}
  end
  
  it_behaves_like "Hud92264::A3::TotalRequirementsForSettlement::PartB" do
    let(:host){@sec223f_acquisition}
  end

  describe "Hud92264::A3::TotalRequirementsForSettlement::PartB implementation" do
    describe "total_estimated_cash_requirement" do
      specify {@sec223f_acquisition.total_estimated_cash_requirement.should be > 0}
    end
  end
  
  describe "Sec223fCashRequirement implementation" do
    
    it "should be an instance of Sec223fCashRequirement" do
      @sec223f_acquisition.should be_a_kind_of Sec223fCashRequirement
    end
    
    describe "#estimate_of_repair_cost" do
      it "should not raise NotImplementedError" do
        lambda do
          @sec223f_acquisition.estimate_of_repair_cost
        end.should_not raise_error NotImplementedError
      end
    end
    
    describe "grant_or_loan" do
      
      let(:expected) {500_000}
      
      after do
        mod_attrs = @initialization_attrs.merge(:criterion_11=>@crit_11_attrs)
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new mod_attrs
        @sec223f_acquisition.grant_or_loan.should == expected
      end
      
      it "should be the value of any tax_credits supplied" do
        @crit_11_attrs = @criterion_7_attrs.merge(:tax_credits=>expected)
      end
      
      it "should be the value of any gifts supplied" do
        @crit_11_attrs = @criterion_7_attrs.merge(:gifts=>expected)
      end
      
      it "should be the value of any grants supplied" do
        @crit_11_attrs = @criterion_7_attrs.merge(:grants=>expected)
      end
      
      it "should be the value of any public_loans supplied" do
        @crit_11_attrs = @criterion_7_attrs.merge(:public_loans=>expected)
      end
      
      it "should be the value of any private_loans supplied" do
        @crit_11_attrs = @criterion_7_attrs.merge(:private_loans=>expected)
      end
    end
    
    describe "#mortgage_amount" do
      it "should not raise NotImplementedError" do
        lambda do
          @sec223f_acquisition.mortgage_amount
        end.should_not raise_error NotImplementedError
      end
    end
    
    describe "#total_development_costs" do
      it "should be total of all items" do
        @criterion_7_attrs[:financing_fee_is_percent_of_loan] = true
        @criterion_7_attrs[:financing_fee] = 2.0
        @criterion_7_attrs[:discounts_rate] = 1.5
        @criterion_7_attrs[:permanent_placement_rate] = 1.5
        @criterion_7_attrs[:exam_fee_rate] = 0.3
        @criterion_7_attrs[:first_year_mortgage_insurance_premium_rate] = 1.0
        @criterion_7_attrs[:title_and_recording_is_percent_of_loan] = true
        @criterion_7_attrs[:title_and_recording] = 0.07
        loan_amount = 10_000_000
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_receive(:maximum_insurable_mortgage).any_number_of_times.and_return loan_amount
        expected = @criterion_7_attrs[:initial_deposit_to_replacement_reserve]
        expected += @criterion_7_attrs[:repairs_and_improvements]
        expected += @sec223f_acquisition.fha_inspection_fee
        expected += @sec223f_acquisition.financing_fee
        expected += @sec223f_acquisition.discount
        expected += @sec223f_acquisition.permanent_placement_fee
        expected += @sec223f_acquisition.fha_exam_fee
        expected += @sec223f_acquisition.first_year_mip
        expected += @sec223f_acquisition.legal_and_organizational
        expected += @sec223f_acquisition.survey
        expected += @sec223f_acquisition.other
        expected += @sec223f_acquisition.third_party_reports
        expected += @sec223f_acquisition.title_and_recording
        @sec223f_acquisition.total_development_costs.should be_within(0.005).of expected
      end
    end
  end
  
  describe "as_json" do
    it "should contain loan with criteria 1, 3, 4, 5 & 7 and maximum_insurable_mortgage" do
      json = @sec223f_acquisition.as_json[:loan]
      json.size.should == 6
      json[:criterion_1].should == {:loan_request=>@loan_request}
      json[:criterion_3].should == @sec223f_acquisition.criterion_3.as_json
      json[:criterion_4].should == @sec223f_acquisition.criterion_4.as_json
      json[:criterion_5].should == @sec223f_acquisition.criterion_5.as_json
      json[:criterion_7].should == @sec223f_acquisition.criterion_7.as_json
      expected_mortgage_max = @sec223f_acquisition.maximum_insurable_mortgage
      json[:maximum_insurable_mortgage].should == expected_mortgage_max
    end
    
    context "criterion_11 given" do
      it "should include the criterion" do
        crit_11_attributes = @criterion_7_attrs.dup.merge(:tax_credits=>500_000)
        obj = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs.merge(:criterion_11=>crit_11_attributes)
        json = obj.as_json[:loan]
        json.size.should == 7
        json[:criterion_11].should == obj.criterion_11.as_json
      end
    end
    
    it "should contain total_estimated_cash_requirement" do
      expected = @sec223f_acquisition.total_estimated_cash_requirement
      @sec223f_acquisition.as_json[:total_estimated_cash_requirement].should == expected
    end
  end
  
  describe "errors_as_json" do
    it "should include invalid inputs uniquely associated with each criterion" do
      @criterion_11_attrs[:tax_credits] = -1 # uniquely a criterion 11 error
      @criterion_7_attrs[:purchase_price_of_project] = -1 # uniquely a criterion 7 error
      @criterion_3_attrs[:value_in_fee_simple] = -1 # uniquely a criterion 3 error
      @criterion_4_attrs[:high_cost_percentage] = nil # uniquely a criterion 4 error
      @initialization_attrs[:loan_request] = -1 # criterion 1 error
      @criterion_5_attrs[:mortgage_insurance_premium_rate] = -1 # uniquely a criterion 5 error
      @initialization_attrs[:criterion_11] = @criterion_11_attrs
      @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
      @sec223f_acquisition.should_not be_valid
      json = @sec223f_acquisition.errors_as_json
      json.size.should == 7
      json[:value_in_fee_simple].should == ["must be greater than or equal to 0"]
      json[:tax_credits].should == ["must be greater than or equal to 0"]
      json[:purchase_price_of_project].should == ['must be greater than or equal to 0']
      json[:high_cost_percentage].should == ["is not a number"]
      json[:loan_request].should == ['Loan request (criterion_1) must be greater than or equal to 0']
      json[:mortgage_insurance_premium_rate].should == ['must be greater than or equal to 0']
      json[:debt_service_constant].should == ['is not a number']
    end
    
    it "should include only one error message for an attribute invalid in the same way for criteria 7 & 11" do
      [@criterion_7_attrs, @criterion_11_attrs].each { |a| a[:repairs_and_improvements] = -1 }
      @initialization_attrs[:criterion_11] = @criterion_11_attrs
      @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
      @sec223f_acquisition.should_not be_valid
      @sec223f_acquisition.criterion_11.should_not be_valid
      @sec223f_acquisition.criterion_7.should_not be_valid
      json = @sec223f_acquisition.errors_as_json
      json.size.should == 1
      json[:repairs_and_improvements].should == ["must be greater than or equal to 0"]
    end
    
    it "should include only one error message for an attribute invalid in the same way for criteria 3, 4 & 5" do
      [@criterion_5_attrs, @criterion_4_attrs, @criterion_3_attrs].each { |a| a[:percent_multiplier] = -1 }
      @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
      @sec223f_acquisition.should_not be_valid
      @sec223f_acquisition.criterion_3.should_not be_valid
      @sec223f_acquisition.criterion_4.should_not be_valid
      @sec223f_acquisition.criterion_5.should_not be_valid
      json = @sec223f_acquisition.errors_as_json #ActiveSupport::JSON.decode @sec223f_acquisition.errors_to_json
      json.size.should == 1
      json[:percent_multiplier].should == ["must be greater than or equal to 0"]
    end
    
    it "should include multiple error messages for an attribute invalid in as many ways for criteria 3, 4 & 5" do
      @criterion_5_attrs[:percent_multiplier] = -1
      @criterion_4_attrs[:percent_multiplier] = nil
      @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
      @sec223f_acquisition.should_not be_valid
      @sec223f_acquisition.criterion_4.should_not be_valid
      @sec223f_acquisition.criterion_5.should_not be_valid
      json = @sec223f_acquisition.errors_as_json #ActiveSupport::JSON.decode @sec223f_acquisition.errors_to_json
      json.size.should == 1
      json[:percent_multiplier].should include "must be greater than or equal to 0"
      json[:percent_multiplier].should include "is not a number"
    end
    
    it "should contain errors related to gross income" do
      @criterion_5_attrs[:gross_residential_income] = -1
      @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
      json = @sec223f_acquisition.errors_as_json 
      json.size.should == 1
      json[:gross_residential_income].should == ['must be greater than or equal to 0']
    end
    
    context "when lease invalid" do
      it "should contain unique errors in a nested lease space" do
        attributes = {:first_year_payment=>2400, :term_in_years=>50,
                      :as_is_value_of_land_in_fee_simple=>-1,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
        @initialization_attrs[:lease] = attributes
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
        json = @sec223f_acquisition.errors_as_json
        json[:lease][:as_is_value_of_land_in_fee_simple].should == ['must be greater than or equal to 0']
      end
      
      it "should not report errors for loan_interest_rate_percent" do
        attributes = {:first_year_payment=>2400, :term_in_years=>50,
                      :as_is_value_of_land_in_fee_simple=>1_000_000,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
        @initialization_attrs[:lease] = attributes
        @criterion_5_attrs[:mortgage_interest_rate] = -1
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
        json = @sec223f_acquisition.errors_as_json
        json[:mortgage_interest_rate].should == ["must be greater than or equal to 0"]
        json[:lease].should be nil
      end
    end
    
    context "when tax_abatement invalid" do
      it "should contain unique errors in a nested tax_abatement space" do
        abatement = {:end_year=>35, :annual_amount=>-5_000}
        @initialization_attrs[:tax_abatement] = abatement
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
        json = @sec223f_acquisition.errors_as_json
        json.size.should == 1
        json[:tax_abatement][:annual_amount].should == ['must be greater than or equal to 0']
      end
      
      it "should not report errors for mortgage_interest_rate" do
        @criterion_5_attrs[:mortgage_interest_rate] = nil
        abatement = {:end_year=>35, :annual_amount=>5_000}
        @initialization_attrs[:tax_abatement] = abatement
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
        json = @sec223f_acquisition.errors_as_json
        json[:mortgage_interest_rate].should == ["is not a number"]
        json[:tax_abatement].should be nil
      end
      
      it "should not report errors for mortgage_insurance_premium_percent" do
        @criterion_5_attrs[:mortgage_insurance_premium_rate] = -1
        abatement = {:end_year=>35, :annual_amount=>5_000}
        @initialization_attrs[:tax_abatement] = abatement
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
        json = @sec223f_acquisition.errors_as_json
        json[:mortgage_insurance_premium_rate].should == ["must be greater than or equal to 0"]
        json[:tax_abatement].should be nil
      end
      
      it "should not report errors for loan_term_in_months" do
        @criterion_5_attrs[:term_in_months] = -1
        abatement = {:end_year=>35, :annual_amount=>5_000}
        @initialization_attrs[:tax_abatement] = abatement
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
        json = @sec223f_acquisition.errors_as_json
        json[:term_in_months].should == ["must be greater than 0"]
        json[:tax_abatement].should be nil
      end
    end
  end
  
  describe "errors_to_json" do
    it "should call errors_as_json" do
      @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
      @sec223f_acquisition.should_receive :errors_as_json
      @sec223f_acquisition.errors_to_json
    end
  end
  
  describe "validations" do
    it "should not be valid when criterion_7 is invalid" do
      @sec223f_acquisition.criterion_7.percent_multiplier = -0.01
      @sec223f_acquisition.should_not be_valid
    end
    
    context "when criterion_11 is present" do
      it "should not be valid when criterion_11 is invalid" do
        @criterion_11_attrs[:tax_credits] = -1
        @initialization_attrs[:criterion_11] = @criterion_11_attrs
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
      end
    end
    
    context "when lease is present" do
      it "should not be valid when lease is invalid" do
        attributes = {:first_year_payment=>2400, :term_in_years=>50,
                      :as_is_value_of_land_in_fee_simple=>-1,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
        @initialization_attrs[:lease] = attributes
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
      end
    end
    
    context "when tax_abatement is present" do
      it "should not be valid when tax_abatement is invalid" do
        @initialization_attrs[:tax_abatement] = {:end_year=>5, :annual_amount=>-5_000}
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.should_not be_valid
      end
    end
  end
  
  describe "criterion_3" do
    context "when suitable lease given" do
      it "should have positive value_of_leased_fee" do
        attributes = {:first_year_payment=>2400, :term_in_years=>50,
                      :as_is_value_of_land_in_fee_simple=>1_000_000,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
        @initialization_attrs[:lease] = attributes
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_3.value_of_leased_fee.should == attributes[:as_is_value_of_land_in_fee_simple]
      end
    end
  end
  
  
  describe "criterion_4" do
    context "when lease given" do
      it "should have positive value_of_leased_fee" do
        attributes = {:first_year_payment=>2400, :term_in_years=>50,
                      :as_is_value_of_land_in_fee_simple=>1_000_000,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
        @initialization_attrs[:lease] = attributes
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_4.value_of_leased_fee.should == attributes[:as_is_value_of_land_in_fee_simple]
      end
    end
  end
  
  describe "criterion_5" do
    
    before do
      @initialization_attrs[:criterion_5][:mortgage_interest_rate] = 7.5
      @initialization_attrs[:criterion_5][:mortgage_insurance_premium_rate] = 0.5
      @initialization_attrs[:criterion_5][:term_in_months] = 35 * 12
    end
    
    context "when lease given" do
      it "should have positive expected annual_ground_rent" do
        attributes = {:first_year_payment=>2400, :term_in_years=>50,
                      :as_is_value_of_land_in_fee_simple=>1_000_000,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
        @initialization_attrs[:lease] = attributes
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_5.annual_ground_rent.should be == attributes[:first_year_payment]
      end
    end
    
    context "when variable tax abatement given" do
      it "should have expected positive tax_abatement_present_value and no annual_tax_abatement" do
        abatement = {:variable_phase_1=>{:start_year=>10, :end_year=>15, :annual_amount=>5_000},
                     :variable_phase_2=>{:start_year=> 0, :end_year=>5, :annual_amount=>25_000},
                     :variable_phase_3=>{:start_year=>5, :end_year=>10, :annual_amount=>10_000}}
        @initialization_attrs[:tax_abatement] = abatement
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_5.tax_abatement_present_value.should be_within(1.0).of 138_037
        @sec223f_acquisition.criterion_5.annual_tax_abatement.should be nil
      end
    end
    
    context "when short term abatement given" do
      it "should have expected positive tax_abatement_present_value and no annual_tax_abatement" do
        abatement = {:end_year=>5, :annual_amount=>5_000}
        @initialization_attrs[:tax_abatement] = abatement
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_5.tax_abatement_present_value.should be_within(0.005).of 20_370.30
        @sec223f_acquisition.criterion_5.annual_tax_abatement.should be nil
      end
    end
    
    context "when fixed long-term abatement given" do
      it "should have no tax_abatement_present_value and expected positive annual_tax_abatement" do
        abatement = {:end_year=>35, :annual_amount=>5_000}
        @initialization_attrs[:tax_abatement] = abatement
        @initialization_attrs[:criterion_5][:tax_abatement_present_value] = nil # remove this initialization val!
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_5.tax_abatement_present_value.should be nil
        @sec223f_acquisition.criterion_5.annual_tax_abatement.should == abatement[:annual_amount]
      end
    end
  end
  
  describe "criterion_7 after initialization" do
    
    it "should be instance of Criterion7" do
      @sec223f_acquisition.criterion_7.should be_an_instance_of Criterion7::Criterion7
    end
    
    it "should have the criterion_7 attributes given in the initialization" do
      @criterion_7_attrs.each_pair do |attr, val|
        (@sec223f_acquisition.criterion_7.send attr).should be_within(0.005).of(val)
      end
    end
    
    context "fha_inspection_fee not given" do
      it "should have an fha_inspection_fee that is presumably a f'n of the number of apartments" do
        @criterion_7_attrs.has_key?(:fha_inspection_fee).should be false
        @sec223f_acquisition.criterion_7.fha_inspection_fee.should be > 0
      end
    end
    
    context "fha_inspection_fee given" do
      it "should have an fha_inspection_fee that is a f'n of the number of apartments" do
        @criterion_7_attrs[:fha_inspection_fee] = expected = 25_000
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_7.fha_inspection_fee.should == expected
      end
    end
    
  end
  
  describe "criterion_11" do
    context "when suitable lease given" do
      it "should have positive value_of_leased_fee" do
        attributes = {:first_year_payment=>2400, :term_in_years=>50,
                      :as_is_value_of_land_in_fee_simple=>1_000_000,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
        @initialization_attrs[:lease] = attributes
        @initialization_attrs[:criterion_11] = @criterion_11_attrs
        @sec223f_acquisition = Sec223fAcquisition::Sec223fAcquisition.new @initialization_attrs
        @sec223f_acquisition.criterion_11.value_of_leased_fee.should == attributes[:as_is_value_of_land_in_fee_simple]
      end
    end
  end
  
  describe "maximum_insurable_mortgage" do
    
    it "should be criterion_1 when that criterion is the min" do
      @expected = 10_000
      @sec223f_acquisition.criterion_1 = @expected
      @sec223f_acquisition.stub_chain(:criterion_3, :line_e => 40_000)
      @sec223f_acquisition.stub_chain(:criterion_4, :line_g => 20_000)
      @sec223f_acquisition.stub_chain(:criterion_5, :line_j => 30_000)
      @sec223f_acquisition.stub_chain(:criterion_7, :line_h => 60_000)
      @sec223f_acquisition.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_3 when that criterion is the min" do
      @expected = 10_000
      @sec223f_acquisition.stub_chain(:criterion_3, :line_e => @expected)
      @sec223f_acquisition.stub_chain(:criterion_4, :line_g => 20_000)
      @sec223f_acquisition.stub_chain(:criterion_5, :line_j => 30_000)
      @sec223f_acquisition.stub_chain(:criterion_7, :line_h => 60_000)
      @sec223f_acquisition.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_4 when that criterion is the min" do
      @expected = 10_000
      @sec223f_acquisition.stub_chain(:criterion_3, :line_e => 20_000)
      @sec223f_acquisition.stub_chain(:criterion_4, :line_g => @expected)
      @sec223f_acquisition.stub_chain(:criterion_5, :line_j => 30_000)
      @sec223f_acquisition.stub_chain(:criterion_7, :line_h => 60_000)
      @sec223f_acquisition.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_5 when that criterion is the min" do
      @expected = 10_000
      @sec223f_acquisition.stub_chain(:criterion_3, :line_e => 20_000)
      @sec223f_acquisition.stub_chain(:criterion_4, :line_g => 30_000)
      @sec223f_acquisition.stub_chain(:criterion_5, :line_j => @expected)
      @sec223f_acquisition.stub_chain(:criterion_7, :line_h => 60_000)
      @sec223f_acquisition.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_7 when that criterion is the min" do
      @expected = 10_000
      @sec223f_acquisition.stub_chain(:criterion_3, :line_e => 20_000)
      @sec223f_acquisition.stub_chain(:criterion_4, :line_g => 30_000)
      @sec223f_acquisition.stub_chain(:criterion_5, :line_j => 40_000)
      @sec223f_acquisition.stub_chain(:criterion_7, :line_h => @expected)
      @sec223f_acquisition.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_11 when that criterion is the min" do
      @expected = 10_000
      @sec223f_acquisition.should_receive(:criterion_3).and_return double('c3', :line_e=>20_000)
      @sec223f_acquisition.should_receive(:criterion_4).and_return double('c4', :line_g => 30_000)
      @sec223f_acquisition.should_receive(:criterion_5).and_return double('c5', :line_j => 40_000)
      @sec223f_acquisition.should_receive(:criterion_7).and_return double('c7', :line_h => 35_000)
      crit_11 = double('c11', :line_c=>@expected)
      @sec223f_acquisition.should_receive(:criterion_11).any_number_of_times.and_return crit_11
      @sec223f_acquisition.maximum_insurable_mortgage.should == @expected
    end
    
  end
  
end
