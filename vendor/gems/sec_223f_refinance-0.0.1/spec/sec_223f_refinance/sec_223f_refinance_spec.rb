require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "Sec223fRefinance" do
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
    @criterion_10_attrs = {:percent_multiplier => 80, :existing_indebtedness => 12_300_000, 
                           :repairs => 75_000, :legal_and_organizational => 15_000,
                           :initial_deposit_to_replacement_reserve => 30_000, 
                           :value_in_fee_simple=> @criterion_3_attrs[:value_in_fee_simple],
                           :third_party_reports => 15_000, :survey => 5_000, :other => 10_000,
                           :major_movable_equipment => 100_000, :replacement_reserves_on_deposit => 45_000,
                           :first_year_mortgage_insurance_premium_rate => 1, :discounts_rate => 1,
                           :mortgagable_bond_costs_rate => 0.75, :permanent_placement_rate => 0.5,
                           :exam_fee_rate => 0.3}
    @criterion_11_attrs = @criterion_10_attrs.dup.merge(:value_in_fee_simple=>1_000_000)
    @initialization_attrs = {:criterion_3 => @criterion_3_attrs, :criterion_4 => @criterion_4_attrs, 
                             :loan_request => @loan_request,
                             :criterion_5 => @criterion_5_attrs, :criterion_10 => @criterion_10_attrs}
    @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
  end
  
  specify {@sec_223f_refinance.should be_valid}
  
  it_behaves_like "Hud92013::Attachments::DevelopmentCosts" do
    let(:host){@sec_223f_refinance}
  end
  
  it_behaves_like "Hud92264::A3::TotalRequirementsForSettlement::PartB" do
    let(:host){@sec_223f_refinance}
  end
  
  describe "Hud92264::A3::TotalRequirementsForSettlement::PartB implementation" do
    describe "total_estimated_cash_requirement" do
      specify {@sec_223f_refinance.total_estimated_cash_requirement.should be > 0}
    end
  end
  
  describe "Sec223fCashRequirement implementation" do
    
    it "should be an instance of Sec223fCashRequirement" do
      @sec_223f_refinance.should be_a_kind_of Sec223fCashRequirement
    end
    
    describe "#estimate_of_repair_cost" do
      it "should not raise NotImplementedError" do
        lambda do
          @sec_223f_refinance.estimate_of_repair_cost
        end.should_not raise_error NotImplementedError
      end
    end
    
    describe "grant_or_loan" do
      
      let(:expected) {500_000}
      
      after do
        mod_attrs = @initialization_attrs.merge(:criterion_11=>@criterion_11_attrs)
        @sec223f_refinance = Sec223fRefinance::Sec223fRefinance.new mod_attrs
        @sec223f_refinance.grant_or_loan.should == expected
      end
      
      it "should be the value of any tax_credits supplied" do
        @criterion_11_attrs.merge!(:tax_credits=>expected)
      end
      
      it "should be the value of any gifts supplied" do
        @criterion_11_attrs.merge!(:gifts=>expected)
      end
      
      it "should be the value of any grants supplied" do
        @criterion_11_attrs.merge!(:grants=>expected)
      end
      
      it "should be the value of any public_loans supplied" do
        @criterion_11_attrs.merge!(:public_loans=>expected)
      end
      
      it "should be the value of any private_loans supplied" do
        @criterion_11_attrs.merge!(:private_loans=>expected)
      end
    end
    
    describe "#mortgage_amount" do
      it "should not raise NotImplementedError" do
        lambda do
          @sec_223f_refinance.mortgage_amount
        end.should_not raise_error NotImplementedError
      end
    end
    
    describe "#total_development_costs" do
      it "should be total of all items" do
        @criterion_10_attrs[:financing_fee_is_percent_of_loan] = true
        @criterion_10_attrs[:financing_fee] = 2.0
        @criterion_10_attrs[:discounts_rate] = 1.5
        @criterion_10_attrs[:permanent_placement_rate] = 1.5
        @criterion_10_attrs[:exam_fee_rate] = 0.3
        @criterion_10_attrs[:first_year_mortgage_insurance_premium_rate] = 1.0
        @criterion_10_attrs[:title_and_recording_is_percent_of_loan] = true
        @criterion_10_attrs[:title_and_recording] = 0.07
        loan_amount = 10_000_000
        @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        @sec_223f_refinance.should_receive(:maximum_insurable_mortgage).any_number_of_times.and_return loan_amount
        expected = @criterion_10_attrs[:initial_deposit_to_replacement_reserve]
        expected += @criterion_10_attrs[:repairs]
        expected += @sec_223f_refinance.fha_inspection_fee
        expected += @sec_223f_refinance.financing_fee
        expected += @sec_223f_refinance.discount
        expected += @sec_223f_refinance.permanent_placement_fee
        expected += @sec_223f_refinance.fha_exam_fee
        expected += @sec_223f_refinance.first_year_mip
        expected += @sec_223f_refinance.legal_and_organizational
        expected += @sec_223f_refinance.survey
        expected += @sec_223f_refinance.other
        expected += @sec_223f_refinance.third_party_reports
        expected += @sec_223f_refinance.title_and_recording
        @sec_223f_refinance.total_development_costs.should be_within(0.005).of expected
      end
    end
    
  end
  
  describe "as_json" do
    it "should contain loan with criteria 1, 3, 4, 5 & 10 and maximum_insurable_mortgage" do
      json = @sec_223f_refinance.as_json[:loan]
      json.size.should == 6
      json[:criterion_1].should == {:loan_request=>@loan_request}
      json[:criterion_3].should == @sec_223f_refinance.criterion_3.as_json
      json[:criterion_4].should == @sec_223f_refinance.criterion_4.as_json
      json[:criterion_5].should == @sec_223f_refinance.criterion_5.as_json
      json[:criterion_10].should == @sec_223f_refinance.criterion_10.as_json
      expected_mortgage_max = @sec_223f_refinance.maximum_insurable_mortgage
      json[:maximum_insurable_mortgage].should == expected_mortgage_max
    end
    
    context "criterion_11 given" do
      it "should include the criterion" do
        crit_11_attributes = @criterion_10_attrs.dup.merge(:tax_credits=>500_000)
        obj = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs.merge(:criterion_11=>crit_11_attributes)
        json = obj.as_json[:loan]
        json.size.should == 7
        json[:criterion_11].should == obj.criterion_11.as_json
      end
    end
    
    it "should contain total_estimated_cash_requirement" do
      expected = @sec_223f_refinance.total_estimated_cash_requirement
      @sec_223f_refinance.as_json[:total_estimated_cash_requirement].should == expected
    end
    
  end
  
  describe "errors_as_json" do
    it "should include invalid inputs uniquely associated with each criterion" do
      @criterion_11_attrs[:tax_credits] = -1 # uniquely a criterion 11 error
      @criterion_10_attrs[:existing_indebtedness] = -1 # uniquely...
      @criterion_3_attrs[:value_in_fee_simple] = -1 # uniquely a criterion 3 error
      @criterion_4_attrs[:high_cost_percentage] = nil # uniquely a criterion 4 error
      @initialization_attrs[:loan_request] = -1 # criterion 1 error
      @criterion_5_attrs[:mortgage_insurance_premium_rate] = -1 # uniquely a criterion 5 error
      @initialization_attrs[:criterion_11] = @criterion_11_attrs
      @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
      @sec_223f_refinance.should_not be_valid
      json = ActiveSupport::JSON.decode @sec_223f_refinance.errors_to_json
      json.size.should == 7
      json['value_in_fee_simple'].should == ["must be greater than or equal to 0"]
      json['existing_indebtedness'].should == ['must be greater than or equal to 0']
      json['high_cost_percentage'].should == ["is not a number"]
      json['tax_credits'].should == ["must be greater than or equal to 0"]
      json['loan_request'].should == ['Loan request (criterion_1) must be greater than or equal to 0']
      json['mortgage_insurance_premium_rate'].should == ['must be greater than or equal to 0']
      json['debt_service_constant'].should == ['is not a number']
    end
    
    it "should include only one error message for an attribute invalid in the same way for criteria 10 & 11" do
      [@criterion_10_attrs, @criterion_11_attrs].each { |a| a[:repairs] = -1 }
      @initialization_attrs[:criterion_11] = @criterion_11_attrs
      @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
      @sec_223f_refinance.should_not be_valid
      @sec_223f_refinance.criterion_11.should_not be_valid
      @sec_223f_refinance.criterion_10.should_not be_valid
      json = @sec_223f_refinance.errors_as_json
      json.size.should == 1
      json[:repairs].should == ["must be greater than or equal to 0"]
    end
    
    it "should include only one error message for an attribute invalid in the same way for criteria 3, 4 & 5" do
      [@criterion_5_attrs, @criterion_4_attrs, @criterion_3_attrs].each { |a| a[:percent_multiplier] = -1 }
      @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
      @sec_223f_refinance.should_not be_valid
      @sec_223f_refinance.criterion_3.should_not be_valid
      @sec_223f_refinance.criterion_4.should_not be_valid
      @sec_223f_refinance.criterion_5.should_not be_valid
      json = ActiveSupport::JSON.decode @sec_223f_refinance.errors_to_json
      json.size.should == 1
      json['percent_multiplier'].should == ["must be greater than or equal to 0"]
    end
    
    it "should include multiple error messages for an attribute invalid in as many ways for multiple criteria" do
      @criterion_5_attrs[:percent_multiplier] = -1
      @criterion_4_attrs[:percent_multiplier] = nil
      @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
      @sec_223f_refinance.should_not be_valid
      @sec_223f_refinance.criterion_4.should_not be_valid
      @sec_223f_refinance.criterion_5.should_not be_valid
      json = ActiveSupport::JSON.decode @sec_223f_refinance.errors_to_json
      json.size.should == 1
      json['percent_multiplier'].should include "must be greater than or equal to 0"
      json['percent_multiplier'].should include "is not a number"
    end
  end
  
  describe "validations" do
    it "should not be valid when criterion_10 is invalid" do
      @sec_223f_refinance.criterion_10.percent_multiplier = -0.01
      @sec_223f_refinance.should_not be_valid
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
        refi = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        refi.criterion_3.value_of_leased_fee.should == attributes[:as_is_value_of_land_in_fee_simple]
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
        @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        @sec_223f_refinance.criterion_4.value_of_leased_fee.should == attributes[:as_is_value_of_land_in_fee_simple]
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
        refi = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        refi.criterion_5.annual_ground_rent.should be == attributes[:first_year_payment]
      end
    end
    
    context "when variable tax abatement given" do
      it "should have expected positive tax_abatement_present_value and no annual_tax_abatement" do
        abatement = {:variable_phase_1=>{:start_year=>10, :end_year=>15, :annual_amount=>5_000},
                     :variable_phase_2=>{:start_year=> 0, :end_year=>5, :annual_amount=>25_000},
                     :variable_phase_3=>{:start_year=>5, :end_year=>10, :annual_amount=>10_000}}
        @initialization_attrs[:tax_abatement] = abatement
        refi = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        refi.criterion_5.tax_abatement_present_value.should be_within(1.0).of 138_037
        refi.criterion_5.annual_tax_abatement.should be nil
      end
    end
    
    context "when short term abatement given" do
      it "should have expected positive tax_abatement_present_value and no annual_tax_abatement" do
        abatement = {:end_year=>5, :annual_amount=>5_000}
        @initialization_attrs[:tax_abatement] = abatement
        refi = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        refi.criterion_5.tax_abatement_present_value.should be_within(0.005).of 20_370.30
        refi.criterion_5.annual_tax_abatement.should be nil
      end
    end
    
    context "when fixed long-term abatement given" do
      it "should have no tax_abatement_present_value and expected positive annual_tax_abatement" do
        abatement = {:end_year=>35, :annual_amount=>5_000}
        @initialization_attrs[:tax_abatement] = abatement
        @initialization_attrs[:criterion_5][:tax_abatement_present_value] = nil # remove this initialization val!
        refi = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        refi.criterion_5.tax_abatement_present_value.should be nil
        refi.criterion_5.annual_tax_abatement.should == abatement[:annual_amount]
      end
    end
  end
  
  describe "criterion_10 after initialization" do
    
    it "should be instance of Criterion10" do
      @sec_223f_refinance.criterion_10.should be_an_instance_of Criterion10::Criterion10
    end
    
    it "should have the criterion_10 attributes given in the initialization" do
      @criterion_10_attrs.each_pair do |attr, val|
        (@sec_223f_refinance.criterion_10.send attr).should be_within(0.005).of(val)
      end
    end
    
    context "fha_inspection_fee not given" do
      it "should have an fha_inspection_fee that is presumably a f'n of the number of apartments" do
        @criterion_10_attrs.has_key?(:fha_inspection_fee).should be false
        @sec_223f_refinance.criterion_10.fha_inspection_fee.should be > 0
      end
    end
    
    context "fha_inspection_fee given" do
      it "should have an fha_inspection_fee that is a f'n of the number of apartments" do
        @criterion_10_attrs[:fha_inspection_fee] = expected = 25_000
        @sec_223f_refinance = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        @sec_223f_refinance.criterion_10.fha_inspection_fee.should == expected
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
        refi = Sec223fRefinance::Sec223fRefinance.new @initialization_attrs
        refi.criterion_11.value_of_leased_fee.should == attributes[:as_is_value_of_land_in_fee_simple]
      end
    end
  end
  
  describe "maximum_insurable_mortgage" do
    
    it "should be criterion_1 when that criterion is the min" do
      @expected = 10_000
      @sec_223f_refinance.criterion_1 = @expected
      @sec_223f_refinance.stub_chain(:criterion_3, :line_e => 40_000)
      @sec_223f_refinance.stub_chain(:criterion_4, :line_g => 20_000)
      @sec_223f_refinance.stub_chain(:criterion_5, :line_j => 30_000)
      @sec_223f_refinance.stub_chain(:criterion_10, :line_i => 60_000)
      @sec_223f_refinance.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_3 when that criterion is the min" do
      @expected = 10_000
      @sec_223f_refinance.stub_chain(:criterion_3, :line_e => @expected)
      @sec_223f_refinance.stub_chain(:criterion_4, :line_g => 20_000)
      @sec_223f_refinance.stub_chain(:criterion_5, :line_j => 30_000)
      @sec_223f_refinance.stub_chain(:criterion_10, :line_i => 60_000)
      @sec_223f_refinance.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_4 when that criterion is the min" do
      @expected = 10_000
      @sec_223f_refinance.stub_chain(:criterion_3, :line_e => 20_000)
      @sec_223f_refinance.stub_chain(:criterion_4, :line_g => @expected)
      @sec_223f_refinance.stub_chain(:criterion_5, :line_j => 30_000)
      @sec_223f_refinance.stub_chain(:criterion_10, :line_i => 60_000)
      @sec_223f_refinance.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_5 when that criterion is the min" do
      @expected = 10_000
      @sec_223f_refinance.stub_chain(:criterion_3, :line_e => 20_000)
      @sec_223f_refinance.stub_chain(:criterion_4, :line_g => 30_000)
      @sec_223f_refinance.stub_chain(:criterion_5, :line_j => @expected)
      @sec_223f_refinance.stub_chain(:criterion_10, :line_i => 60_000)
      @sec_223f_refinance.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_10 when that criterion is the min" do
      @expected = 10_000
      @sec_223f_refinance.stub_chain(:criterion_3, :line_e => 20_000)
      @sec_223f_refinance.stub_chain(:criterion_4, :line_g => 30_000)
      @sec_223f_refinance.stub_chain(:criterion_5, :line_j => 40_000)
      @sec_223f_refinance.stub_chain(:criterion_10, :line_i => @expected)
      @sec_223f_refinance.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_11 when that criterion is the min" do
      @expected = 10_000
      @sec_223f_refinance.should_receive(:criterion_3).and_return double('c3', :line_e=>20_000)
      @sec_223f_refinance.should_receive(:criterion_4).and_return double('c4', :line_g => 30_000)
      @sec_223f_refinance.should_receive(:criterion_5).and_return double('c5', :line_j => 40_000)
      @sec_223f_refinance.should_receive(:criterion_10).and_return double('c10', :line_i => 35_000)
      crit_11 = double('c11', :line_c=>@expected)
      @sec_223f_refinance.should_receive(:criterion_11).any_number_of_times.and_return crit_11
      @sec_223f_refinance.maximum_insurable_mortgage.should == @expected
    end
    
  end
  
end
