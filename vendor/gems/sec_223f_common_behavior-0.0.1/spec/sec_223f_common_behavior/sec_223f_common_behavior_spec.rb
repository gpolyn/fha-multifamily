require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "Sec223fCommonBehavior" do
  before(:each) do
    @criterion_3_attrs = {:value_in_fee_simple => 1_000_000, :percent_multiplier => 85, 
                          :value_of_leased_fee => 5_000, 
                          :excess_unusual_land_improvement => 4_000,
                          :cost_containment_mortgage_deduction => 5_000, 
                          :unpaid_balance_of_special_assessments => 10_000}
    @criterion_5_attrs = {:mortgage_interest_rate=>5.5, :percent_multiplier=>85, 
                          :mortgage_insurance_premium_rate=>0.45, :gross_residential_income=>1_000_000,
                          :residential_occupancy_percent=>90, 
                          :operating_expenses_is_percent_of_effective_gross_income=>false,
                          :maximum_residential_occupancy_percent=>93, 
                          :minimum_residential_occupancy_percent=>85,
                          :operating_expenses=>500_000, :annual_replacement_reserve=>10_000, 
                          :annual_tax_abatement=>40_000, :annual_ground_rent=> 10_000,
                          :annual_special_assessment => 10_000, :term_in_months => 420,
                          :tax_abatement_present_value=> 10_000}
    @loan_request = 10_000_000
    @criterion_4_attrs = {:high_cost_percentage => 270, :is_elevator_project => true, 
                          :number_of_no_bedroom_units => 10, :percent_multiplier =>85,
                          :number_of_one_bedroom_units => 11, :number_of_two_bedroom_units => 12, 
                          :number_of_three_bedroom_units => 13, :number_of_four_or_more_bedroom_units => 14,
                          :warranted_price_of_land => 1_000_000,
                          :value_of_leased_fee => 1_000_000, 
                          :gross_apartment_square_feet=>50_000, :project_value=>1_000_000,
                          :unpaid_balance_of_special_assessments => 100_000}
    class TestClass; include Sec223fCommonBehavior; end
    @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                    :criterion_4 => @criterion_4_attrs,
                                    :criterion_5 => @criterion_5_attrs,
                                    :loan_request => @loan_request)
  end
  
  describe "some shit" do
    it "should be some..." do
      @criterion_4_attrs[:number_of_no_bedroom_units] = 5
      @criterion_4_attrs[:number_of_one_bedroom_units] = 5
      @criterion_4_attrs[:number_of_two_bedroom_units] = 5
      @criterion_4_attrs[:number_of_three_bedroom_units] = 1
      @criterion_4_attrs[:number_of_four_or_more_bedroom_units] = 5
      
      @criterion_5_attrs = {:mortgage_interest_rate=>5.5, :percent_multiplier=>83.3, 
                            :mortgage_insurance_premium_rate=>0.45, :gross_residential_income=>502000,
                            :residential_occupancy_percent=>95, 
                            :operating_expenses_is_percent_of_effective_gross_income=>true,
                            :maximum_residential_occupancy_percent=>92.5,
                            :gross_commercial_income=>125000, :commercial_occupancy_percent=>90,
                            :maximum_commercial_occupancy_percent=>80,
                            :minimum_residential_occupancy_percent=>85,
                            :operating_expenses=>40, :term_in_months => 420}
      
      # @criterion_5_attrs[:gross_residential_income] = 502000
      # @criterion_5_attrs[:residential_occupancy_percent] = 95
      # @criterion_5_attrs[:operating_expenses_is_percent_of_effective_gross_income] = true
      # @criterion_5_attrs[:maximum_residential_occupancy_percent] = 92.5
      # @criterion_5_attrs[:gross_commercial_income] = 100000
      # @criterion_5_attrs[:commercial_occupancy_percent] = 80
      # @criterion_5_attrs[:operating_expenses] = 40
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @criterion_5_attrs,
                                      :annual_replacement_reserve_per_unit => 250,
                                      :loan_request => @loan_request)
      p "shshsh #{@commonBehavior.criterion_5.to_json}"
    end
  end
  
  describe "to_json representation" do
    it "should be comprised of expected values" do
      @commonBehavior.loan_request = crit_1 = 10_000_000
      json = ActiveSupport::JSON.decode @commonBehavior.to_json
      json['criterion_1']['loan_request'].should == crit_1
      json['criterion_3'].should == ActiveSupport::JSON.decode(@commonBehavior.criterion_3.to_json)
      json['criterion_4'].should == ActiveSupport::JSON.decode(@commonBehavior.criterion_4.to_json)
      json['criterion_5'].should == ActiveSupport::JSON.decode(@commonBehavior.criterion_5.to_json)
    end
  end
  
  describe "errors.as_json" do
    
    context "when attributes contributing to criterion 5 fields are invalid" do
      
      context "when criterion 5 debt service constraint is concerned" do
        
        after(:each) {@commonBehavior.errors.as_json[:criterion_5][:debt_service_constant].should == ["is not a number"]}
        
        it "should include term in months and criterion 5 debt service constraint" do
          @criterion_5_attrs[:term_in_months] = nil
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs,
                                          :loan_request => 10_000_000)
          @commonBehavior.should_not be_valid
          @commonBehavior.errors.size.should == 1
          @commonBehavior.errors.as_json[:term_in_months].should == ["is not a number"]
        end
        
        it "should include criterion 5 debt service constraint and mortgage_insurance_premium_rate" do
          @criterion_5_attrs[:mortgage_insurance_premium_rate] = nil
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs,
                                          :loan_request => 10_000_000)
          @commonBehavior.should_not be_valid
          @commonBehavior.errors.as_json[:criterion_5][:mortgage_insurance_premium_rate].should == ["is not a number"]
        end
        
        it "should include criterion 5 debt service constraint and mortgage_interest_rate" do
          @criterion_5_attrs[:mortgage_interest_rate] = nil
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs,
                                          :loan_request => 10_000_000)
          @commonBehavior.should_not be_valid
          @commonBehavior.errors.as_json[:criterion_5][:mortgage_interest_rate].should == ["is not a number"]
        end
        
      end
      
      context "when criteron 5 operating expenses and effective income are concerned" do
        
        it "should include gri and criterion 5 opex, egi when gri is invalid" do
          @criterion_5_attrs[:gross_residential_income] = nil
          @criterion_5_attrs[:operating_expenses] = 40
          @criterion_5_attrs[:operating_expenses_is_percent_of_effective_gross_income] = true
          
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs,
                                          :loan_request => 10_000_000)
          @commonBehavior.should_not be_valid
          @commonBehavior.errors.size.should == 1
          
          
          @commonBehavior.errors.as_json[:gross_residential_income].should == ["is not a number"]
          @commonBehavior.errors.as_json[:criterion_5][:operating_expenses].should == ["is not a number"]
          @commonBehavior.errors.as_json[:criterion_5][:effective_income].should == ["is not a number"]
        end
        
      end
      
      context "when criteron 5 operating expenses is concerned" do
        
        after(:each) do
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs,
                                          :loan_request => 10_000_000)
          @commonBehavior.should_not be_valid
          @commonBehavior.errors.size.should == 1
          @commonBehavior.errors.as_json[@common_attr_sym].should == @common_attr_error_arr
          @commonBehavior.errors.as_json[:criterion_5][:operating_expenses].should == ["is not a number"]
        end
        
        it "should include operating_expenses and criterion 5 effective income when operating_expenses invalid" do
          @criterion_5_attrs[:operating_expenses] = nil
          @common_attr_sym = :operating_expenses
          @common_attr_error_arr = ["is not a number"]
        end

        it "should include operating_expenses as pct and criterion 5 effective income when operating_expenses as pct invalid" do
          @criterion_5_attrs[:operating_expenses_is_percent_of_effective_gross_income] = "some invalid value"
          @common_attr_sym = :operating_expenses_is_percent_of_effective_gross_income
          @common_attr_error_arr = ["must be one of true, false or nil"]
        end
        
      end
      
      context "when criterion 5 effective income is concerned" do
        
        after(:each) do
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs,
                                          :loan_request => 10_000_000)
          @commonBehavior.should_not be_valid
          @commonBehavior.errors.size.should == 1
          @commonBehavior.errors.as_json[@common_attr_sym].should == @common_attr_error_arr
          @commonBehavior.errors.as_json[:criterion_5][:effective_income].should == ["is not a number"]
        end
        
        it "should include g.r.i. and criterion 5 effective income when g.r.i. invalid" do
          @criterion_5_attrs[:gross_residential_income] = nil
          @common_attr_sym = :gross_residential_income
          @common_attr_error_arr = ["is not a number"]
        end
        
        it "should include g.c.i. and criterion 5 effective income when g.c.i. invalid" do
          @criterion_5_attrs[:gross_commercial_income] = -1
          @criterion_5_attrs[:maximum_commercial_occupancy_percent] = 80
          @criterion_5_attrs[:commercial_occupancy_percent] = 75
          @common_attr_sym = :gross_commercial_income
          @common_attr_error_arr = ["must be greater than or equal to 0"]
        end
        
        it "should include comm occ % and criterion 5 effective income when comm occ % invalid" do
          @criterion_5_attrs[:gross_commercial_income] = 100
          @criterion_5_attrs[:maximum_commercial_occupancy_percent] = 80
          @criterion_5_attrs[:commercial_occupancy_percent] = -1
          @common_attr_sym = :commercial_occupancy_percent
          @common_attr_error_arr = ["must be greater than or equal to 0"]
        end
        
        it "should include max comm occ % and criterion 5 effective income when max comm occ % invalid" do
          @criterion_5_attrs[:gross_commercial_income] = 100
          @criterion_5_attrs[:maximum_commercial_occupancy_percent] = -1
          @criterion_5_attrs[:commercial_occupancy_percent] = 75
          @common_attr_sym = :maximum_commercial_occupancy_percent
          @common_attr_error_arr = ["must be greater than or equal to 0"]
        end
        
        it "should include res occ % and criterion 5 effective income when res occ % invalid" do
          @criterion_5_attrs[:residential_occupancy_percent] = nil
          @common_attr_sym = :residential_occupancy_percent
          @common_attr_error_arr = ["is not a number"]
        end

        it "should include max res occ % and criterion 5 effective income when max res occ % invalid" do
          @criterion_5_attrs[:maximum_residential_occupancy_percent] = nil
          @common_attr_sym = :maximum_residential_occupancy_percent
          @common_attr_error_arr = ["is not a number"]
        end

        it "should include min res occ % and criterion 5 effective income when min res occ % invalid" do
          @criterion_5_attrs[:minimum_residential_occupancy_percent] = nil
          @common_attr_sym = :minimum_residential_occupancy_percent
          @common_attr_error_arr = ["is not a number"]
        end
        
      end
      
    end

  end
  
  describe "errors.to_json" do
    it "should contain errors attribute for criteria/attributes that have errors" do
      @criterion_3_attrs[:value_in_fee_simple] = -1
      @criterion_4_attrs[:indoor_commercial_parking_square_feet] = -1
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @criterion_5_attrs,
                                      :loan_request => -1)
      @commonBehavior.should_not be_valid
      error_json = ActiveSupport::JSON.decode @commonBehavior.errors.to_json
      # 3...
      @commonBehavior.criterion_3.errors.size.should == 1
      expected = @commonBehavior.criterion_3.errors['value_in_fee_simple']
      error_json['criterion_3']['value_in_fee_simple'].should == expected
      # 4        
      @commonBehavior.criterion_4.errors.size.should == 1
      expected = @commonBehavior.criterion_4.errors['indoor_commercial_parking_square_feet']
      error_json['criterion_4']['indoor_commercial_parking_square_feet'].should == expected
      # 5
      @commonBehavior.criterion_5.errors.size.should == 2
      expected = @commonBehavior.criterion_5.errors['tax_abatement_present_value']
      error_json['criterion_5']['tax_abatement_present_value'].should == expected
      expected = @commonBehavior.criterion_5.errors['annual_tax_abatement']
      error_json['criterion_5']['annual_tax_abatement'].should == expected
      # common attributes
      @commonBehavior.errors.size.should == 1
      error_json['loan_request'].should == ["Loan request (criterion_1) must be greater than or equal to 0"]
    end
  end
  
  describe "residential_occupancy_percent_is_greater_than_or_equal_to_minimum" do

    it "should not be valid when residential occupancy < minimum" do
      @crit_5_mod = @criterion_5_attrs.clone
      @crit_5_mod[:minimum_residential_occupancy_percent] = 85
      @crit_5_mod[:residential_occupancy_percent] = 84.99
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @crit_5_mod,
                                      :loan_request => @loan_request)
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      err_msg = "must be greater than or equal to minimum residential occupancy percent"
      @commonBehavior.errors[:residential_occupancy_percent].should == [err_msg]
    end
  end
  
  describe "operating_expenses validation" do
    
    before(:each) {@crit_5_mod = @criterion_5_attrs.clone}
    
    after(:each) do
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @crit_5_mod, 
                                      :loan_request => @loan_request)
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      @commonBehavior.errors[@sym].should == [@msg]
    end
    
    it "should be invalid when opex as percent is not {true, false, nil}" do
      @crit_5_mod[:operating_expenses_is_percent_of_effective_gross_income] = 22
      @sym = :operating_expenses_is_percent_of_effective_gross_income
      @msg = "must be one of true, false or nil"
    end
    
    it "should be invalid when opex as percent is true but opex > 100" do
      @crit_5_mod[:operating_expenses_is_percent_of_effective_gross_income] = true
      @crit_5_mod[:operating_expenses] = 100.01
      @sym = :operating_expenses
      @msg = "must be less than or equal to 100"
    end
    
    it "should be invalid when opex < 0" do
      @crit_5_mod[:operating_expenses] = -0.01
      @sym = :operating_expenses
      @msg = "must be greater than or equal to 0"
    end
    
    
  end
  
  describe "replacement reserve validations" do
    
    after(:each) do
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @criterion_5_attrs,
                                      :annual_replacement_reserve_per_unit=>@annual_per_unit,
                                      :minimum_annual_replacement_reserve_per_unit=>@min_annual_per_unit, 
                                      :loan_request => @loan_request)
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal @errors || 1
      if @err_arr
        @err_arr.each {|ele| @commonBehavior.errors[ele.first].should == [ele.last]}
      else
        @commonBehavior.errors[@sym].should == [@msg]
      end
    end
    
    describe "minimum_annual_replacement_reserve_per_unit_validations" do
      it "should be greater than or equal to 0 if present" do
        @annual_per_unit = 400
        @min_annual_per_unit = -1
        @sym = :minimum_annual_replacement_reserve_per_unit
        @msg = "must be greater than or equal to 0"
      end
    end

    describe "annual_replacement_reserve_per_unit validations" do
      
      context "when valid minimum_annual_replacement_reserve_per_unit_validations present" do
        
        before(:each) do
          @min_annual_per_unit = 250
          @sym = :annual_replacement_reserve_per_unit
        end
        
        it "should be greater than or equal to minimum" do
          @annual_per_unit = 249.99
          @msg = "must be greater than or equal to #{@min_annual_per_unit}"
        end

        it "should be present" do
          @msg = "is not a number"
        end
      end
      
      context "when invalid minimum_annual_replacement_reserve_per_unit_validations present" do
        it "should be greater than 0" do
          @annual_per_unit = -1
          @min_annual_per_unit = -1
          msg = "must be greater than or equal to 0"
          @err_arr = [[:annual_replacement_reserve_per_unit, msg]]
          @err_arr << [:minimum_annual_replacement_reserve_per_unit, msg]
          @errors = 2
        end
      end
      
      context "when no minimum_annual_replacement_reserve_per_unit_validations present" do
        it "should be greater than 0" do
          @annual_per_unit = -1
          @sym = :annual_replacement_reserve_per_unit
          @msg = "must be greater than or equal to 0"
        end
      end
      
    end
  end
  
  describe "attributes that are required" do
    
    before(:each) {@crit_5_mod = @criterion_5_attrs.clone}
    
    after(:each) do
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @crit_5_mod, 
                                      :loan_request => @loan_request)
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      @commonBehavior.errors[@sym].should == ["is not a number"]
    end

    it "should include residential_occupancy_percent" do
      @crit_5_mod[:residential_occupancy_percent] = nil
      @sym = :residential_occupancy_percent
    end
    
    it "should include gross_residential_income" do
      @crit_5_mod[:gross_residential_income] = nil
      @sym = :gross_residential_income
    end
    
    it "should include maximum_residential_occupancy_percent" do
      @crit_5_mod[:maximum_residential_occupancy_percent] = nil
      @sym = :maximum_residential_occupancy_percent
    end
    
    it "should include minimum_residential_occupancy_percent" do
      @crit_5_mod[:minimum_residential_occupancy_percent] = nil
      @sym = :minimum_residential_occupancy_percent
    end
    
    context "commercial income is present" do
      
      before(:each) {@crit_5_mod[:gross_commercial_income] = 100_000}
      
      it "should include commercial_occupancy_percent" do
        @crit_5_mod[:commercial_occupancy_percent] = nil
        @crit_5_mod[:maximum_commercial_occupancy_percent] = 100
        @sym = :commercial_occupancy_percent
      end
      
      it "should include maximum_commercial_occupancy_percent" do
        @crit_5_mod[:maximum_commercial_occupancy_percent] = nil
        @crit_5_mod[:commercial_occupancy_percent] = 100
        @sym = :maximum_commercial_occupancy_percent
      end
    end
    
  end
  
  describe "attributes that must be less than or equal to 100" do
    
    before(:each) {@crit_5_mod = @criterion_5_attrs.clone}
    
    after(:each) do
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @crit_5_mod, 
                                      :loan_request => @loan_request)
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      @commonBehavior.errors[@sym].should == ["must be less than or equal to 100"]
    end

    it "should include residential_occupancy_percent" do
      @crit_5_mod[:residential_occupancy_percent] = 100.01
      @sym = :residential_occupancy_percent
    end
    
    it "should include maximum_residential_occupancy_percent" do
      @crit_5_mod[:maximum_residential_occupancy_percent] = 100.01
      @sym = :maximum_residential_occupancy_percent
    end
    
    it "should include minimum_residential_occupancy_percent" do
      @crit_5_mod[:minimum_residential_occupancy_percent] = 100.01
      @sym = :minimum_residential_occupancy_percent
    end
    
    context "commercial income is present" do
      
      before(:each) {@crit_5_mod[:gross_commercial_income] = 100_000}
      
      it "should include commercial_occupancy_percent" do
        @crit_5_mod[:commercial_occupancy_percent] = 100.01
        @crit_5_mod[:maximum_commercial_occupancy_percent] = 100
        @sym = :commercial_occupancy_percent
      end
      
      it "should include maximum_commercial_occupancy_percent" do
        @crit_5_mod[:maximum_commercial_occupancy_percent] = 100.01
        @crit_5_mod[:commercial_occupancy_percent] = 100
        @sym = :maximum_commercial_occupancy_percent
      end
    end
    
  end
  
  describe "annual_replacement_reserve_per_unit" do
    it "should not be valid if less than zero" do
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @criterion_5_attrs, 
                                      :annual_replacement_reserve_per_unit=>-1,
                                      :loan_request => @loan_request)
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      @commonBehavior.errors[:annual_replacement_reserve_per_unit].should == ["must be greater than or equal to 0"]
    end
    
  end
  
  describe "attributes that must be greater than or equal to 0" do
    
    before(:each) {@crit_5_mod = @criterion_5_attrs.clone}
    
    after(:each) do
      @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                      :criterion_4 => @criterion_4_attrs,
                                      :criterion_5 => @crit_5_mod, 
                                      :loan_request => @loan_request)
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      @commonBehavior.errors[@sym].should == ["must be greater than or equal to 0"]
    end
      
    it "should include gross_residential_income" do
      @crit_5_mod[:gross_residential_income] = -0.01
      @sym = :gross_residential_income
    end

    it "should include residential_occupancy_percent" do
      @crit_5_mod[:residential_occupancy_percent] = -0.01
      @sym = :residential_occupancy_percent
    end
    
    it "should include minimum_residential_occupancy_percent" do
      @crit_5_mod[:minimum_residential_occupancy_percent] = -0.01
      @sym = :minimum_residential_occupancy_percent
    end
    
    context "commercial income is present" do
      
      before(:each) {@crit_5_mod[:gross_commercial_income] = 100_000}
      
      it "should include gross_commercial_income" do
        @crit_5_mod[:commercial_occupancy_percent] = 75
        @crit_5_mod[:maximum_commercial_occupancy_percent] = 80
        @crit_5_mod[:gross_commercial_income] = -0.01
        @sym = :gross_commercial_income
      end
      
      it "should include maximum_commercial_occupancy_percent" do
        @crit_5_mod[:commercial_occupancy_percent] = 75
        @crit_5_mod[:maximum_commercial_occupancy_percent] = -0.01
        @sym = :maximum_commercial_occupancy_percent
      end
      
      it "should include commercial_occupancy_percent" do
        @crit_5_mod[:maximum_commercial_occupancy_percent] = 80
        @crit_5_mod[:commercial_occupancy_percent] = -0.01
        @sym = :commercial_occupancy_percent
      end
    end
    
  end
  
  describe "term in months validations" do
    
    before(:each) {@crit_5_mod = @criterion_5_attrs.clone}
    
    after(:each) do
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      @commonBehavior.errors[:term_in_months].should == [@error_msg]
    end
    
    context "when passed among criterion_5 attributes" do
      after(:each) do
        @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                        :criterion_4 => @criterion_4_attrs,
                                        :criterion_5 => @crit_5_mod, 
                                        :loan_request => @loan_request)
      end
      
      it "should not be valid when absent" do
        @crit_5_mod[:term_in_months] = nil
        @error_msg = "is not a number"
      end

      it "should not be valid when 0" do
        @crit_5_mod[:term_in_months] = 0
        @error_msg = "must be greater than 0"
      end
      
      it "should not be valid when greater than 420" do
        @crit_5_mod[:term_in_months] = 421
        @error_msg = "must be less than or equal to 420"
      end
    end
    
    context "when added as attribute" do
      it "should not be valid when loan_term passed with criterion 5 attrs is absent" do
        @commonBehavior.term_in_months = nil
        @error_msg = "is not a number"
      end

      it "should not be valid when loan_term passed with criterion 5 attrs 0" do
        @commonBehavior.term_in_months = 0
        @error_msg = "must be greater than 0"
      end
      
      it "should not be valid when greater than 420" do
        @commonBehavior.term_in_months = 421
        @error_msg = "must be less than or equal to 420"
      end
    end
    
  end
  
  describe "other validations" do
    before(:each) {@negative_decimal = -0.01}
    after(:each) {@commonBehavior.should_not be_valid}
    
    it "should not be valid when loan_request is less than 0" do
      @commonBehavior.loan_request = @negative_decimal
      error_msg = "Loan request (criterion_1) must be greater than or equal to 0"
      @commonBehavior.should_not be_valid
      @commonBehavior.errors.size.should equal 1
      @commonBehavior.errors[:loan_request].should == [error_msg]
    end
    
    it "should be invalid when criterion_3 is invalid" do
      @commonBehavior.criterion_3.value_in_fee_simple = @negative_decimal
    end
    
    it "should be invalid when criterion_4 is invalid" do
      @commonBehavior.criterion_4.high_cost_percentage = @negative_decimal
    end
    
    it "should not be valid when criterion_5 is invalid" do
      @commonBehavior.criterion_5.mortgage_interest_rate = @negative_decimal
    end
    
  end
  
  describe "criterion_1 after initialization" do
    it "should equal the value given as the loan request" do
      @commonBehavior.criterion_1.should equal @loan_request
    end
  end
  
  describe "relationship between loan_request and criterion_1" do
    it "should be such that loan_request is considered an alias for criterion_1" do
      @commonBehavior.loan_request = 1234567
      @commonBehavior.criterion_1.should equal @commonBehavior.loan_request
      @commonBehavior.criterion_1 = 7654321
      @commonBehavior.loan_request.should equal @commonBehavior.criterion_1
    end
    
    describe "loan_request after initialization" do
      it "should equal criterion_1" do
        @commonBehavior.loan_request.should equal @commonBehavior.criterion_1
      end
    end
  end
  
  describe "criterion_3 after initialization" do
    
    it "should be instance of Criterion3" do
      @commonBehavior.criterion_3.should be_an_instance_of Criterion3::Criterion3
    end
    
    it "should have all the criterion_3 attributes given in the initialization" do
      @criterion_3_attrs.each_pair do |attr, val|
        (@commonBehavior.criterion_3.send attr).should be_within(0.005).of(val)
      end
    end
  end
  
  describe "criterion_4 after initialization" do
    it "should be instance of criterion_4" do
      @commonBehavior.criterion_4.should be_an_instance_of Criterion4::Criterion4AcceptingCNAParameters
    end
    
    it "should have the numeric criterion_4 attributes given in the initialization" do
      @criterion_4_attrs.delete(:is_elevator_project)
      @criterion_4_attrs.each_pair do |attr, val|
        (@commonBehavior.criterion_4.send attr).should be_within(0.005).of(val)
      end
    end
    
    it "should have is_elevator_project set at value given in initialization" do
      @commonBehavior.criterion_4.is_elevator_project.should equal @criterion_4_attrs[:is_elevator_project]
    end
  end
  
  describe "criterion_5 after initialization" do
    
    it "should be instance of Criterion5" do
      @commonBehavior.criterion_5.should be_an_instance_of Criterion5::Criterion5
    end
    
    it "should have the criterion_5 attributes given in the initialization, except the special items" do
      special_items = [:term_in_months, :gross_residential_income, :gross_commercial_income, 
                       :commercial_occupancy_percent, :residential_occupancy_percent, 
                       :operating_expenses_is_percent_of_effective_gross_income, :annual_replacement_reserve,
                       :maximum_commercial_occupancy_percent, :gross_residential_income,
                       :minimum_residential_occupancy_percent, :maximum_residential_occupancy_percent]
      special_items.each {|attr| @criterion_5_attrs.delete(attr)}
      @criterion_5_attrs.each_pair do |attr, val|
        (@commonBehavior.criterion_5.send attr).should be_within(0.005).of(val)
      end
    end
    
    describe "annual_replacement_reserve" do
      
      before(:each) {@criterion_5_attrs[:annual_replacement_reserve] = @some_int}
      
      it "should be as expected when there are units and a valid annual rfr per unit" do
        rfr_per_unit = 250
        @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                        :criterion_4 => @criterion_4_attrs,
                                        :criterion_5 => @criterion_5_attrs,
                                        :annual_replacement_reserve_per_unit => rfr_per_unit,
                                        :loan_request => @loan_request)
        expected = @commonBehavior.criterion_4.total_apartments * rfr_per_unit
        @commonBehavior.criterion_5.annual_replacement_reserve.should == expected
        expected.should_not == @some_int
      end
      
      it "should be nil when no units and a valid annual rfr per unit" do
        [:number_of_no_bedroom_units, :number_of_one_bedroom_units, :number_of_two_bedroom_units,
         :number_of_three_bedroom_units, :number_of_four_or_more_bedroom_units].each {|ele| @criterion_4_attrs[ele] = nil}
        @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                        :criterion_4 => @criterion_4_attrs,
                                        :criterion_5 => @criterion_5_attrs,
                                        :annual_replacement_reserve_per_unit => 240,
                                        :loan_request => @loan_request)
        @commonBehavior.criterion_5.annual_replacement_reserve.should be nil
      end
      
      it "should be nil when units and invalid annual rfr per unit" do
        @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                        :criterion_4 => @criterion_4_attrs,
                                        :criterion_5 => @criterion_5_attrs,
                                        :annual_replacement_reserve_per_unit => -1,
                                        :loan_request => @loan_request)
        @commonBehavior.criterion_5.annual_replacement_reserve.should be nil
      end
      
    end
    
    it "should have a debt_service_constant attribute, properly calculated" do
      args = {}
      args[:mortgage_interest_rate] = @criterion_5_attrs[:mortgage_interest_rate]
      args[:mortgage_insurance_premium_rate] = @criterion_5_attrs[:mortgage_insurance_premium_rate]
      args[:term_in_months] = @criterion_5_attrs[:term_in_months]
      expected = Criterion5::debt_service_constant_percent(args)
      @commonBehavior.criterion_5.debt_service_constant.should be_within(0.0005).of(expected)
    end
    
    describe "net income" do
      context "when annual_replacement_reserve_per_unit is provided" do
        it "should include effect of rfr per unit" do
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs,
                                          :annual_replacement_reserve_per_unit=>250,
                                          :loan_request => @loan_request)
          annual_rfr = @commonBehavior.criterion_4.total_apartments * 
                       @commonBehavior.annual_replacement_reserve_per_unit
          expected = @commonBehavior.criterion_5.effective_income - 
                     @commonBehavior.criterion_5.operating_expenses - annual_rfr +
                     @commonBehavior.criterion_5.annual_tax_abatement
          @commonBehavior.criterion_5.net_income.should be_within(0.005).of expected
        end
      end
    end
    
    describe "effective gross income" do
      
      after(:each) do
        @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                        :criterion_4 => @criterion_4_attrs,
                                        :criterion_5 => @criterion_5_attrs, 
                                        :loan_request => @loan_request)
        @commonBehavior.criterion_5.effective_income.should be_within(0.005).of @expected
      end
      
      context "when only residential income provided" do
        
        after(:each) { @expected = @criterion_5_attrs[:gross_residential_income].to_f * @pct }
        
        context "when occupancy rate < max occupancy rate" do
          it "should be product of gross residential and occupancy" do
            @criterion_5_attrs[:maximum_residential_occupancy_percent] = 93
            @criterion_5_attrs[:residential_occupancy_percent] = 92.45
            @pct = @criterion_5_attrs[:residential_occupancy_percent]/100
          end
        end
        
        context "when occupancy rate > max occupancy rate" do
          it "should be product of gross residential and max occupancy" do
            @criterion_5_attrs[:residential_occupancy_percent] = 93
            @criterion_5_attrs[:maximum_residential_occupancy_percent] = 92.45
            @pct = @criterion_5_attrs[:maximum_residential_occupancy_percent]/100
          end
        end
        
      end
      
      context "when commercial income also provided" do
        
        before(:each) do
          @criterion_5_attrs[:maximum_residential_occupancy_percent] = 93
          @criterion_5_attrs[:residential_occupancy_percent] = 92.45
          @criterion_5_attrs[:gross_commercial_income] = 300_000
          pct = @criterion_5_attrs[:residential_occupancy_percent]/100
          @residential = pct * @criterion_5_attrs[:gross_residential_income]
        end
        
        after(:each) {@expected = @commercial + @residential}
        
        context "when occupancy rate < max occupancy rate" do
          it "should be fn incl. product of gross commercial and occupancy" do
            @criterion_5_attrs[:maximum_commercial_occupancy_percent] = 80
            @criterion_5_attrs[:commercial_occupancy_percent] = 79.5
            @commercial = @criterion_5_attrs[:commercial_occupancy_percent]/100 * 
                          @criterion_5_attrs[:gross_commercial_income]
          end
        end
        
        context "when occupancy rate > max occupancy rate" do
          it "should be fn incl. gross commercial and max occupancy" do
            @criterion_5_attrs[:commercial_occupancy_percent] = 80
            @criterion_5_attrs[:maximum_commercial_occupancy_percent] = 79.5
            @commercial = @criterion_5_attrs[:maximum_commercial_occupancy_percent]/100 * 
                          @criterion_5_attrs[:gross_commercial_income]
          end
        end
      end
    end
    
    describe "operating expenses" do
      it "should be in dollar terms when opex as pct of egi is false" do
        @commonBehavior.criterion_5.operating_expenses.should be_within(0.005).of @criterion_5_attrs[:operating_expenses]
      end
      
      it "should be in dollar terms when opex as pct of egi is nil" do
        @criterion_5_attrs[:operating_expenses_is_percent_of_effective_gross_income] = nil
        @commonBehavior.criterion_5.operating_expenses.should be_within(0.005).of @criterion_5_attrs[:operating_expenses]
      end
      
      context "when opex as pct of egi" do
        
        before(:each) do
          @criterion_5_attrs[:operating_expenses] = 40
          @criterion_5_attrs[:operating_expenses_is_percent_of_effective_gross_income] = true
        end
        
        after(:each) do
          @commonBehavior = TestClass.new(:criterion_3 => @criterion_3_attrs,
                                          :criterion_4 => @criterion_4_attrs,
                                          :criterion_5 => @criterion_5_attrs, 
                                          :loan_request => @loan_request)
          @commonBehavior.criterion_5.operating_expenses.should be_within(0.005).of @expected
        end
        
        it "should be the expected value when only residential income supplied" do
          @expected = @criterion_5_attrs[:gross_residential_income] * @criterion_5_attrs[:residential_occupancy_percent].to_f/100 *
                     @criterion_5_attrs[:operating_expenses].to_f/100
        end
        
        it "should be the expected value when commercial income supplied" do
          @criterion_5_attrs[:maximum_commercial_occupancy_percent] = 80
          @criterion_5_attrs[:commercial_occupancy_percent] = 79.5
          @criterion_5_attrs[:gross_commercial_income] = 300_000
          residential = @criterion_5_attrs[:gross_residential_income] * @criterion_5_attrs[:residential_occupancy_percent].to_f/100
          commercial = @criterion_5_attrs[:gross_commercial_income] * @criterion_5_attrs[:commercial_occupancy_percent].to_f/100
          @expected = (residential + commercial) * @criterion_5_attrs[:operating_expenses].to_f/100
        end
        
      end
    end

  end
  
  describe "maximum_insurable_mortgage" do
    
    it "should be criterion_1 when that criterion is the min" do
      @expected = 10_000
      @commonBehavior.criterion_1 = @expected
      @commonBehavior.stub_chain(:criterion_3, :line_e => 40_000)
      @commonBehavior.stub_chain(:criterion_4, :line_g => 20_000)
      @commonBehavior.stub_chain(:criterion_5, :line_j => 30_000)
      @commonBehavior.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_3 when that criterion is the min" do
      @expected = 10_000
      @commonBehavior.stub_chain(:criterion_3, :line_e => @expected)
      @commonBehavior.stub_chain(:criterion_4, :line_g => 20_000)
      @commonBehavior.stub_chain(:criterion_5, :line_j => 30_000)
      @commonBehavior.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_4 when that criterion is the min" do
      @expected = 10_000
      @commonBehavior.stub_chain(:criterion_3, :line_e => 20_000)
      @commonBehavior.stub_chain(:criterion_4, :line_g => @expected)
      @commonBehavior.stub_chain(:criterion_5, :line_j => 30_000)
      @commonBehavior.maximum_insurable_mortgage.should == @expected
    end
    
    it "should be criterion_5 when that criterion is the min" do
      @expected = 10_000
      @commonBehavior.stub_chain(:criterion_3, :line_e => 20_000)
      @commonBehavior.stub_chain(:criterion_4, :line_g => 30_000)
      @commonBehavior.stub_chain(:criterion_5, :line_j => @expected)
      @commonBehavior.maximum_insurable_mortgage.should == @expected
    end
    
  end
  
end

# describe "Criterion5::debt_service_constant_percent" do
#   it "should be the same as some Excel spreadsheet result for the same inputs" do
#     args = {:mortgage_interest_rate=>5.5, :mortgage_insurance_premium_rate=>0.45, :term_in_months=>420}
#     result = Criterion5::debt_service_constant_percent(args)
#     result.should be_within(0.00005).of(6.8942)
#   end
# end
# 
# describe "criterion_5" do
#   
#   before(:each) do
#     @criterion_5 = Criterion5::Criterion5.new(:mortgage_interest_rate=>5.15, 
#                                               :mortgage_insurance_premium_rate=>0.45,
#                                               :debt_service_constant=>6.81)
#     @some_int = 1_000_000
#   end
#   
#   describe "net_income" do
#     
#     before(:each) do
#       @expected = @criterion_5.effective_income = 100_000
#       @expected -= @criterion_5.operating_expenses = 50_000
#     end
#     
#     it "should be income less opex plus annual_tax_abatement less annual_replacement_reserve" do
#       @expected += @criterion_5.annual_tax_abatement = 500
#       @expected -= @criterion_5.annual_replacement_reserve = 1_000
#       @criterion_5.net_income.should == @expected
#     end
#     
#     it "should be income less opex plus annual_tax_abatement" do
#       @expected += @criterion_5.annual_tax_abatement = 500
#       @criterion_5.net_income.should == @expected
#     end
#     
#     it "should be income less opex less annual_replacement_reserve" do
#       @expected -= @criterion_5.annual_replacement_reserve = 1_000
#       @criterion_5.net_income.should == @expected
#     end
#   end
#   
#   describe "line_a" do    
#     it "should be an alias for mortgage_interest_rate" do
#       @criterion_5.line_a.should be_within(0.005).of(@criterion_5.mortgage_interest_rate)
#     end
#   end
#   
#   describe "line_b" do
#     it "should be an alias for mortgage_insurance_premium_rate" do
#       @criterion_5.line_b.should be_within(0.005).of(@criterion_5.mortgage_insurance_premium_rate)
#     end
#   end
#   
#   describe "initial_curtail_rate" do
#     it "should be the debt_service_constant less the mortgage_insurance_premium_rate and mortgage_interest_rate" do
#       expected = @criterion_5.debt_service_constant - @criterion_5.mortgage_insurance_premium_rate -
#                  @criterion_5.mortgage_interest_rate
#       @criterion_5.initial_curtail_rate.should be_within(0.005).of(expected)
#     end
#   end
#   
#   describe "line_c" do
#     it "should be an alias for initial_curtail_rate" do
#       @criterion_5.line_c.should be_within(0.005).of(@criterion_5.initial_curtail_rate)
#     end
#   end
#   
#   describe "line_d" do
#     it "should be an alias for debt_service_constant" do
#       @criterion_5.line_d.should be_within(0.005).of(@criterion_5.debt_service_constant)
#     end
#   end
#   
#   describe "line_e" do
#     it "should be the product of net_income and the percent_multiplier" do
#       @criterion_5.should_receive(:net_income).and_return(@some_int)
#       @criterion_5.percent_multiplier = 87.5
#       expected = @some_int * @criterion_5.percent_multiplier/100
#       @criterion_5.line_e.should be_within(0.005).of(expected)
#     end
#   end
#   
#   describe "line_f" do
#     it "should be the sum of annual_ground_rent and annual_special_assessment" do
#       @criterion_5.annual_ground_rent = @some_int - 1
#       @criterion_5.annual_special_assessment = @some_int + 1
#       expected = @criterion_5.annual_special_assessment + @criterion_5.annual_ground_rent
#       @criterion_5.line_f.should == @criterion_5.line_f
#     end
#     
#     it "should be the annual_ground_rent" do
#       @criterion_5.annual_ground_rent = @some_int
#       @criterion_5.line_f.should == @criterion_5.annual_ground_rent
#     end
#     
#     it "should be the annual_special_assessment" do
#       @criterion_5.annual_special_assessment = @some_int
#       @criterion_5.line_f.should == @criterion_5.annual_special_assessment
#     end
#     
#     it "should be 0" do
#       @criterion_5.line_f.should == 0
#     end
#   end
#   
#   describe "line_g" do
#     it "should be line_e less line_f" do
#       @criterion_5.should_receive(:line_e).and_return(@some_int * 2)
#       @criterion_5.should_receive(:line_f).and_return(@some_int)
#       expected = @some_int
#       @criterion_5.line_g.should == expected
#     end
#   end
#   
#   describe "line_h" do
#     it "should be line_g divided by line_d expressed as a rate" do
#       @criterion_5.should_receive(:line_g).and_return(@some_int)
#       expected = @some_int/(@criterion_5.line_d.to_f/100)
#       @criterion_5.line_h.should be_within(0.005).of(expected)
#     end
#   end
#   
#   describe "line_h_plus_line_i" do
#     it "should be line_h plus line_i to the lowest 100" do
#       @criterion_5.should_receive(:line_h).and_return(1_000)
#       @criterion_5.should_receive(:line_i).and_return(199)
#       expected = 1_100
#       @criterion_5.line_h_plus_line_i.should == expected
#     end
#     
#     it "should be line_h to the lowest 100" do
#       @criterion_5.should_receive(:line_h).and_return(1_099)
#       @criterion_5.line_h_plus_line_i.should == 1_000
#     end
#   end
#   
#   describe "line_j" do
#     it "should be be an alias for line_h_plus_line_i" do
#       @criterion_5.should_receive(:line_h).any_number_of_times.and_return(1_000)
#       @criterion_5.should_receive(:line_i).any_number_of_times.and_return(199)
#       expected = 1_100
#       @criterion_5.line_j.should == @criterion_5.line_h_plus_line_i
#     end
#   end
#   
# end