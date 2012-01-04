require File.dirname(__FILE__) + "/../spec_helper.rb"

describe "CostNotAttributable.calculate" do
  
  before(:each) do
    @cna = Criterion4::CostNotAttributable.new(:gross_apartment_square_feet => 0,
                                               :project_value=>0)
  end
  
  # it "should correctly read-in attribute hashes with string-type keys" do
  #   hash = {"gross_apartment_square_feet" => 200, "project_value" => 300}
  #   @cna = Criterion4::CostNotAttributable.new(hash)
  # end
  
  describe "validations" do
    
    after(:each) do
      @cna.should_not be_valid
      @cna.errors.size.should equal 1
      @cna.errors[@attr_sym].should == [@error_msg]
    end
    
    describe "attributes that must not be blank" do
      before(:each) {@error_msg = "is not a number"}
      
      it "should include gross_apartment_square_feet" do
        @cna.gross_apartment_square_feet = nil
        @attr_sym = :gross_apartment_square_feet
      end
      
      it "should include project_value" do
        @cna.project_value = nil
        @attr_sym = :project_value
      end
      
    end
    
    describe "attributes that must be 0 or greater" do

      before(:each) do
        @error_msg = "must be greater than or equal to 0"
        @negative_number = -0.01
      end

      it "should include outdoor_residential_parking_square_feet" do
        @cna.outdoor_residential_parking_square_feet = @negative_number
        @attr_sym = :outdoor_residential_parking_square_feet
      end

      it "should include indoor_residential_parking_square_feet" do
        @cna.indoor_residential_parking_square_feet = @negative_number
        @attr_sym = :indoor_residential_parking_square_feet
      end

      it "should include outdoor_commercial_parking_square_feet" do
        @cna.outdoor_commercial_parking_square_feet = @negative_number
        @attr_sym = :outdoor_commercial_parking_square_feet
      end

      it "should include indoor_commercial_parking_square_feet" do
        @cna.indoor_commercial_parking_square_feet = @negative_number
        @attr_sym = :indoor_commercial_parking_square_feet
      end

      it "should include outdoor_parking_discount_percent" do
        @cna.outdoor_parking_discount_percent = @negative_number
        @attr_sym = :outdoor_parking_discount_percent
      end

      it "should include gross_apartment_square_feet" do
        @cna.gross_apartment_square_feet = @negative_number
        @attr_sym = :gross_apartment_square_feet
      end

      it "should include gross_other_square_feet" do
        @cna.gross_other_square_feet = @negative_number
        @attr_sym = :gross_other_square_feet
      end

      it "should include gross_commercial_square_feet" do
        @cna.gross_commercial_square_feet = @negative_number
        @attr_sym = :gross_commercial_square_feet
      end

      it "should include project_value" do
        @cna.project_value = @negative_number
        @attr_sym = :project_value
      end

    end
  end
  
  context "when only indoor parking square feet supplied" do
    before(:each) do
      @gross_apartment_square_feet = 85
      @project_value = 100
      @cna = Criterion4::CostNotAttributable.new(:gross_apartment_square_feet => @gross_apartment_square_feet,
                                                 :project_value=>@project_value)
    end
    
    after(:each) {@cna.calculate.should be_within(0.5).of(@expected)}
    
    context "commercial parking" do
      it "should increase with additional parking up to 15%" do
        @cna.calculate.should == 0
        @cna.indoor_commercial_parking_square_feet = parking = 15
        @expected = 0.15 * (@gross_apartment_square_feet + parking)
      end

      it "should remain flat with additional parking after 15%" do
        @cna.indoor_commercial_parking_square_feet = parking = 16
        @expected = 0.15 * (@gross_apartment_square_feet + [parking, 15].min)
      end
    end
    
    context "residential parking" do
      it "should increase with additional parking up to 15%" do
        @cna.calculate.should == 0
        @cna.indoor_residential_parking_square_feet = parking = 15
        @expected = 0.15 * (@gross_apartment_square_feet + parking)
      end

      it "should remain flat with additional parking after 15%" do
        @cna.indoor_residential_parking_square_feet = parking = 16
        @expected = 0.15 * (@gross_apartment_square_feet + [parking, 15].min)
      end
    end
    
  end
  
  context "when only outdoor parking square feet supplied" do
    before(:each) do
      @gross_apartment_square_feet = 85
      @project_value = 100
      @discount = 90.0
      @cna = Criterion4::CostNotAttributable.new(:gross_apartment_square_feet => @gross_apartment_square_feet,
                                                 :outdoor_parking_discount_percent => @discount,
                                                 :project_value => @project_value)
      @factor = (100 - @discount)/100
    end
    
    after(:each) {@cna.calculate.should be_within(0.5).of(@expected)}
    
    context "residential parking" do
      it "should increase with additional parking up to 15%, allowing for outdoor parking discount" do
        @cna.calculate.should == 0
        @cna.outdoor_residential_parking_square_feet = parking = 15/@factor
        @expected = 0.15 * (@gross_apartment_square_feet + parking * @factor)
      end

      it "should remain flat with additional parking after 15%, allowing for outdoor parking discount" do
        @cna.indoor_residential_parking_square_feet = parking = 16/@factor
        @expected = 0.15 * (@gross_apartment_square_feet + [parking, 15].min)
      end
    end
    
    context "commercial parking" do
      it "should increase with additional parking up to 15%, allowing for outdoor parking discount" do
        @cna.calculate.should == 0
        @cna.outdoor_commercial_parking_square_feet = parking = 15/@factor
        @expected = 0.15 * (@gross_apartment_square_feet + parking * @factor)
      end

      it "should remain flat with additional parking after 15%, allowing for outdoor parking discount" do
        @cna.indoor_commercial_parking_square_feet = parking = 16/@factor
        @expected = 0.15 * (@gross_apartment_square_feet + [parking, 15].min)
      end
    end
  end
  
  context "when only commercial space supplied" do
    before(:each) do
      @gross_apartment_square_feet = 85
      @project_value = 100
      @cna = Criterion4::CostNotAttributable.new(:gross_apartment_square_feet => @gross_apartment_square_feet,
                                                 :project_value => @project_value)
    end
    
    it "should increase with additional space up to 15%" do
      @cna.calculate.should == 0
      @cna.gross_commercial_square_feet = commercial = 15
      @expected = 0.15 * (@gross_apartment_square_feet + commercial)
    end

    it "should remain flat with additional space after 15%" do
      @cna.gross_commercial_square_feet = commercial = 16
      @expected = 0.15 * (@gross_apartment_square_feet + [commercial, 15].min)
    end
  end
  
  context "when only other residential space supplied" do
    before(:each) do
      @gross_apartment_square_feet = 85
      @project_value = 100
      @cna = Criterion4::CostNotAttributable.new(:gross_apartment_square_feet => @gross_apartment_square_feet,
                                                 :project_value => @project_value)
    end
    
    it "should increase with additional space up to 15%" do
      @cna.calculate.should == 0
      @cna.gross_other_square_feet = other = 15
      @expected = 0.15 * (@gross_apartment_square_feet + other)
    end

    it "should remain flat with additional space after 15%" do
      @cna.gross_other_square_feet = other = 16
      @expected = 0.15 * (@gross_apartment_square_feet + [other, 15].min)
    end
  end
  
end

describe "criterion_4" do
  
  before(:all) do
    Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = 100
    Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = 200
    Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = 300
    Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = 400
    Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = 500
    Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms = 600
    Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms = 700
    Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms = 800
    Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms = 900
    Criterion4::StatutoryMortgageLimits.elevator_4_plus_bedrooms = 1_000
    Criterion4::StatutoryMortgageLimits.per_space = 1_100
  end
  
  before(:each) do
    @high_cost_percentage = 270
    @criterion_4 = Criterion4::Criterion4.new(:high_cost_percentage=>@high_cost_percentage, 
                                              :number_of_one_bedroom_units=>5, :percent_multiplier=>85)
    @some_int = 100_000
  end
  
  # describe "initialization" do
  #   it "should convert string key-value pairs to expected attributes" do
  #     attrs = {"is_elevator_project"=>"true", "number_of_no_bedroom_units" => "45", 
  #              "high_cost_percentage" => "170"}
  #     criterion_4 = Criterion4::Criterion4.new(attrs)
  #     criterion_4.is_elevator_project.should be true
  #     criterion_4.number_of_no_bedroom_units.should == 45
  #     criterion_4.high_cost_percentage.should == 170
  #   end
  # end
  
  describe "as_json" do
    
    context "apartments" do
      it "should be comprised of 0, nil values when minimal, valid data given (no-br units, arbitrary)" do
        Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = nil
        Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = nil
        Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = nil
        Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = nil
        Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = nil
        attrs = {:high_cost_percentage=>0, :percent_multiplier=>0, :number_of_no_bedroom_units=>5}
        criterion_4 = Criterion4::Criterion4.new attrs
        criterion_4.should be_valid
        json = criterion_4.as_json
        json[:line_a][:number_of_no_bedroom_units][:units].should == attrs[:number_of_no_bedroom_units]
        json[:line_a][:number_of_no_bedroom_units][:per_family_unit_limit].should be nil
        json[:line_a][:number_of_no_bedroom_units][:total].should be nil
        json[:line_a][:number_of_one_bedroom_units][:units].should be nil
        json[:line_a][:number_of_one_bedroom_units][:per_family_unit_limit].should be nil
        json[:line_a][:number_of_one_bedroom_units][:total].should be nil
        json[:line_a][:number_of_two_bedroom_units][:units].should be nil
        json[:line_a][:number_of_two_bedroom_units][:per_family_unit_limit].should be nil
        json[:line_a][:number_of_two_bedroom_units][:total].should be nil
        json[:line_a][:number_of_three_bedroom_units][:units].should be nil
        json[:line_a][:number_of_three_bedroom_units][:per_family_unit_limit].should be nil
        json[:line_a][:number_of_three_bedroom_units][:total].should be nil
        json[:line_a][:number_of_four_or_more_bedroom_units][:units].should be nil
        json[:line_a][:number_of_four_or_more_bedroom_units][:per_family_unit_limit].should be nil
        json[:line_a][:number_of_four_or_more_bedroom_units][:total].should be nil
        json[:line_b][:cost_not_attributable_to_dwelling_use].should be nil
        json[:line_b][:percent_multiplier].should == attrs[:percent_multiplier]
        json[:line_b][:result].should be nil
        json[:line_c][:warranted_price_of_land].should be nil
        json[:line_c][:percent_multiplier].should == attrs[:percent_multiplier]
        json[:line_c][:result].should be nil
        json[:line_d][:total_lines_a_through_c].should be nil
        json[:line_f][:sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments].should be nil
        json[:line_g][:line_d_or_line_e_minus_line_f].should be nil
      end

      it "should be comprised of expected values when all data supplied" do
        hcp = 270.0
        hcp_pct = hcp/100
        Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = non_elevator_0_bedrooms = 45_000 
        Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = non_elevator_1_bedrooms = 47_000
        Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = non_elevator_2_bedrooms = 49_000
        Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = non_elevator_3_bedrooms = 51_000
        Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = non_elevator_4_plus_bedrooms = 53_000
        non_elevator_0_bedrooms *= hcp_pct
        non_elevator_1_bedrooms *= hcp_pct
        non_elevator_2_bedrooms *= hcp_pct
        non_elevator_3_bedrooms *= hcp_pct
        non_elevator_4_plus_bedrooms *= hcp_pct
        attrs = {:number_of_no_bedroom_units=>10, :number_of_one_bedroom_units=> 12, :number_of_two_bedroom_units=>14,
                 :number_of_three_bedroom_units=>16, :number_of_four_or_more_bedroom_units=>18, :percent_multiplier=>101,
                 :is_elevator_project=>false, :cost_not_attributable_to_dwelling_use=>500_000, :high_cost_percentage=>hcp,
                 :warranted_price_of_land=>1_000_000, :value_of_leased_fee=>50_000, 
                 :unpaid_balance_of_special_assessments=>24_000}
        criterion_4 = Criterion4::Criterion4.new attrs
        criterion_4.should be_valid
        json = criterion_4.as_json
        json[:line_a][:number_of_no_bedroom_units][:units].should == attrs[:number_of_no_bedroom_units]
        json[:line_a][:number_of_no_bedroom_units][:per_family_unit_limit].should be_within(0.005).of non_elevator_0_bedrooms
        json[:line_a][:number_of_no_bedroom_units][:total].should == criterion_4.number_of_no_bedroom_units_product
        json[:line_a][:number_of_one_bedroom_units][:units].should == attrs[:number_of_one_bedroom_units]
        json[:line_a][:number_of_one_bedroom_units][:per_family_unit_limit].should be_within(0.005).of non_elevator_1_bedrooms
        json[:line_a][:number_of_one_bedroom_units][:total].should == criterion_4.number_of_one_bedroom_units_product
        json[:line_a][:number_of_two_bedroom_units][:units].should == attrs[:number_of_two_bedroom_units]
        json[:line_a][:number_of_two_bedroom_units][:per_family_unit_limit].should be_within(0.005).of non_elevator_2_bedrooms
        json[:line_a][:number_of_two_bedroom_units][:total].should == criterion_4.number_of_two_bedroom_units_product
        json[:line_a][:number_of_three_bedroom_units][:units].should == attrs[:number_of_three_bedroom_units]
        json[:line_a][:number_of_three_bedroom_units][:per_family_unit_limit].should be_within(0.005).of non_elevator_3_bedrooms
        json[:line_a][:number_of_three_bedroom_units][:total].should == criterion_4.number_of_three_bedroom_units_product
        json[:line_a][:number_of_four_or_more_bedroom_units][:units].should == attrs[:number_of_four_or_more_bedroom_units]
        json[:line_a][:number_of_four_or_more_bedroom_units][:per_family_unit_limit].should be_within(0.005).of non_elevator_4_plus_bedrooms
        json[:line_a][:number_of_four_or_more_bedroom_units][:total].should == criterion_4.number_of_four_or_more_bedroom_units_product
        json[:line_b][:cost_not_attributable_to_dwelling_use].should == attrs[:cost_not_attributable_to_dwelling_use]
        json[:line_b][:percent_multiplier].should == attrs[:percent_multiplier]
        json[:line_b][:result].should == criterion_4.line_b
        json[:line_c][:warranted_price_of_land].should == attrs[:warranted_price_of_land]
        json[:line_c][:percent_multiplier].should == attrs[:percent_multiplier]
        json[:line_c][:result].should == criterion_4.line_c
        json[:line_d][:total_lines_a_through_c].should == criterion_4.line_d
        expected = criterion_4.sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments
        json[:line_f][:sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments].should == expected
        json[:line_g][:line_d_or_line_e_minus_line_f].should == criterion_4.line_d_or_line_e_minus_line_f
      end
    end
    
  end
  
  describe "total_apartments" do
    it "should be expected total of valid apartment counts" do
      expected = @criterion_4.number_of_no_bedroom_units = 10
      expected += @criterion_4.number_of_two_bedroom_units = 11
      expected += @criterion_4.number_of_one_bedroom_units = 12
      expected += @criterion_4.number_of_three_bedroom_units = 13
      expected += @criterion_4.number_of_four_or_more_bedroom_units = 14
      @criterion_4.total_apartments.should == expected
    end
    
    it "should be nil for any negative apartment counts" do
      @criterion_4.number_of_no_bedroom_units = 10
      @criterion_4.number_of_two_bedroom_units = 11
      @criterion_4.number_of_one_bedroom_units = -12
      @criterion_4.number_of_three_bedroom_units = 13
      @criterion_4.number_of_four_or_more_bedroom_units = 14
      @criterion_4.total_apartments.should be nil
    end
    
    it "should be nil for any non-integer apartment counts" do
      @criterion_4.number_of_no_bedroom_units = 10
      @criterion_4.number_of_two_bedroom_units = 11
      @criterion_4.number_of_one_bedroom_units = "Adele"
      @criterion_4.number_of_three_bedroom_units = 13
      @criterion_4.number_of_four_or_more_bedroom_units = 14
      @criterion_4.total_apartments.should be nil
    end
    
    it "should be nil for any non-nil, non-numeric apartment counts" do
      @criterion_4.number_of_no_bedroom_units = 10
      @criterion_4.number_of_two_bedroom_units = 11
      @criterion_4.number_of_one_bedroom_units = "Adele"
      @criterion_4.number_of_three_bedroom_units = 13
      @criterion_4.number_of_four_or_more_bedroom_units = 14
      @criterion_4.total_apartments.should be nil
    end
    
    it "should be nil for any float apartment counts" do
      @criterion_4.number_of_no_bedroom_units = 10
      @criterion_4.number_of_two_bedroom_units = 11
      @criterion_4.number_of_one_bedroom_units = 11.2
      @criterion_4.number_of_three_bedroom_units = 13
      @criterion_4.number_of_four_or_more_bedroom_units = 14
      @criterion_4.total_apartments.should be nil
    end
    
    it "should be add nil as 0" do
      @criterion_4.number_of_no_bedroom_units = nil
      expected = @criterion_4.number_of_two_bedroom_units = 11
      @criterion_4.number_of_one_bedroom_units = nil
      expected += @criterion_4.number_of_three_bedroom_units = 13
      expected += @criterion_4.number_of_four_or_more_bedroom_units = 14
      @criterion_4.total_apartments.should == expected
    end
  end
  
  describe "validations of states that result in one-plus attributes in error" do
    
    describe "total_number_of_spaces_blank_then_apartment_units_greater_than_4 when no spaces" do
      
      after(:each) do
        @criterion_4.should_not be_valid
        @criterion_4.errors.size.should equal 5
        [:number_of_two_bedroom_units, :number_of_four_or_more_bedroom_units, :number_of_no_bedroom_units,
         :number_of_three_bedroom_units, :number_of_one_bedroom_units].each do |key|
           @criterion_4.errors[key].should include 'must contribute to a total of at least five apartments'
         end
      end
      
      it "should add an error to each bedroom count attribute when no units" do
        @criterion_4.number_of_one_bedroom_units = nil
      end
      
      it "should add an error to each bedroom count attribute when less than 5 units associated with one unit type" do
        @criterion_4.number_of_one_bedroom_units = 4
      end
      
      it "should add an error to each bedroom count attribute when less than 5 units associated with +1 unit type" do
        @criterion_4.number_of_one_bedroom_units = 2
        @criterion_4.number_of_one_bedroom_units = 2
      end
    end
    
    describe "not_both_of_total_number_of_spaces_and_units_by_any_bedroom_type_present when spaces present" do
      
      before(:each) do
        attrs = {:high_cost_percentage=>@high_cost_percentage, :percent_multiplier=>85, :total_number_of_spaces=>20}
        @criterion_4 = Criterion4::Criterion4.new attrs
      end
      
      after(:each) do
        @criterion_4.should_not be_valid
        @criterion_4.errors.size.should equal 6
        [:number_of_two_bedroom_units, :number_of_four_or_more_bedroom_units, :number_of_no_bedroom_units,
         :number_of_three_bedroom_units, :number_of_one_bedroom_units].each do |key|
           @criterion_4.errors[key].should include 'mutually exclusive with total_number_of_spaces'
         end
         err = "mutually exclusive with apartments units of any type"
         @criterion_4.errors[:total_number_of_spaces].should include err
      end
      
      it "should add errors to all five apt unit types and total_number_of_spaces when 0-br present" do
        @criterion_4.number_of_no_bedroom_units = 5
      end
      
      it "should add errors to all five apt unit types and total_number_of_spaces when 1-br present" do
        @criterion_4.number_of_one_bedroom_units = 5
      end
      
      it "should add errors to all five apt unit types and total_number_of_spaces when 2-br present" do
        @criterion_4.number_of_two_bedroom_units = 5
      end
      
      it "should add errors to all five apt unit types and total_number_of_spaces when 3-br present" do
        @criterion_4.number_of_three_bedroom_units = 5
      end
      
      it "should add errors to all five apt unit types and total_number_of_spaces when 4-br present" do
        @criterion_4.number_of_four_or_more_bedroom_units = 5
      end
      
    end
    
  end
  
  describe "validations" do
    
    after(:each) do
      @criterion_4.should_not be_valid
      @criterion_4.errors.size.should equal 1
      @criterion_4.errors[@attr_sym].should == [@error_msg]
    end
    
    it "should not be valid when is_elevator_project is not one of true, false or nil" do
      @criterion_4.is_elevator_project = "Tuesday"
      @attr_sym = :is_elevator_project
      @error_msg = "must be one of true, false or nil"
    end
    
    it "should not be valid without high_cost_percentage" do
      @criterion_4.high_cost_percentage = nil
      @attr_sym = :high_cost_percentage
      @error_msg = "is not a number"
    end
    
    it "should not be valid without percent_multiplier" do
      @criterion_4.percent_multiplier = nil
      @attr_sym = :percent_multiplier
      @error_msg = "is not a number"
    end
    
    describe "attributes that must be integers" do
      
      before(:each) do
        @error_msg = "must be an integer"
        @somePositiveDecimal = 5.1
      end
      
      it "should include number_of_no_bedroom_units" do
        @criterion_4.number_of_no_bedroom_units = @somePositiveDecimal
        @attr_sym = :number_of_no_bedroom_units
      end
      
      it "should include number_of_one_bedroom_units" do
        @criterion_4.number_of_one_bedroom_units = @somePositiveDecimal
        @attr_sym = :number_of_one_bedroom_units
      end
      
      it "should include number_of_two_bedroom_units" do
        @criterion_4.number_of_two_bedroom_units = @somePositiveDecimal
        @attr_sym = :number_of_two_bedroom_units
      end
      
      it "should include number_of_three_bedroom_units" do
        @criterion_4.number_of_three_bedroom_units = @somePositiveDecimal
        @attr_sym = :number_of_three_bedroom_units
      end
      
      it "should include number_of_four_or_more_bedroom_units" do
        @criterion_4.number_of_four_or_more_bedroom_units = @somePositiveDecimal
        @attr_sym = :number_of_four_or_more_bedroom_units
      end
      
      it "should include total_number_of_spaces" do
        @criterion_4.number_of_one_bedroom_units = nil # only one of spaces or apartments permitted
        @criterion_4.total_number_of_spaces = @somePositiveDecimal
        @attr_sym = :total_number_of_spaces
      end
    end
    
    describe "attributes that must be non-negative" do
      
      before(:each) do
        @error_msg = "must be greater than or equal to 0"
        @negative_integer = -1
        @negative_decimal = -0.01
        @six_units = 6
      end
      
      it "should include high_cost_percentage" do
        @criterion_4.high_cost_percentage = @negative_decimal
        @attr_sym = :high_cost_percentage
      end
      
      it "should include percent_multiplier" do
        @criterion_4.percent_multiplier = @negative_decimal
        @attr_sym = :percent_multiplier
      end
      
      it "should include number_of_no_bedroom_units" do
        @criterion_4.number_of_one_bedroom_units = @six_units
        @criterion_4.number_of_no_bedroom_units = @negative_integer
        @attr_sym = :number_of_no_bedroom_units
      end
      
      it "should include number_of_one_bedroom_units" do
        @criterion_4.number_of_no_bedroom_units = @six_units
        @criterion_4.number_of_one_bedroom_units = @negative_integer
        @attr_sym = :number_of_one_bedroom_units
      end
      
      it "should include number_of_two_bedroom_units" do
        @criterion_4.number_of_no_bedroom_units = @six_units
        @criterion_4.number_of_two_bedroom_units = @negative_integer
        @attr_sym = :number_of_two_bedroom_units
      end
      
      it "should include number_of_three_bedroom_units" do
        @criterion_4.number_of_no_bedroom_units = @six_units
        @criterion_4.number_of_three_bedroom_units = @negative_integer
        @attr_sym = :number_of_three_bedroom_units
      end
      
      it "should include number_of_four_or_more_bedroom_units" do
        @criterion_4.number_of_no_bedroom_units = @six_units
        @criterion_4.number_of_four_or_more_bedroom_units = @negative_integer
        @attr_sym = :number_of_four_or_more_bedroom_units
      end
      
      it "should include total_number_of_spaces" do
        @criterion_4.number_of_one_bedroom_units = nil
        @criterion_4.total_number_of_spaces = @negative_integer
        @attr_sym = :total_number_of_spaces
      end
      
      it "should include cost_not_attributable_to_dwelling_use" do
        @criterion_4.cost_not_attributable_to_dwelling_use = @negative_decimal
        @attr_sym = :cost_not_attributable_to_dwelling_use
      end
      
      it "should include warranted_price_of_land" do
        @criterion_4.warranted_price_of_land = @negative_decimal
        @attr_sym = :warranted_price_of_land
      end
      
      it "should include value_of_leased_fee" do
        @criterion_4.value_of_leased_fee = @negative_decimal
        @attr_sym = :value_of_leased_fee
      end
      
      it "should include unpaid_balance_of_special_assessments" do
        @criterion_4.unpaid_balance_of_special_assessments = @negative_decimal
        @attr_sym = :unpaid_balance_of_special_assessments
      end
    end
    
  end
  
  context "non-elevator project" do
    
    context "nil expected" do
      describe "number_of_no_bedroom_units_product" do
        it "should be nil when no units present" do
          @criterion_4.number_of_no_bedroom_units = nil
          @criterion_4.number_of_no_bedroom_units_product.should be nil
        end
        
        it "should be nil when no stat limit present" do
          @criterion_4.number_of_no_bedroom_units = 24
          original_val = Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms
          Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = nil
          @criterion_4.number_of_no_bedroom_units_product.should be nil
          Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = original_val # restore
        end
      end
      
      describe "number_of_one_bedroom_units_product" do
        it "should be nil when no units present" do
          @criterion_4.number_of_one_bedroom_units = nil
          @criterion_4.number_of_one_bedroom_units_product.should be nil
        end
        
        it "should be nil when no stat limit present" do
          @criterion_4.number_of_one_bedroom_units = 24
          original_val = Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms
          Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = nil
          @criterion_4.number_of_one_bedroom_units_product.should be nil
          Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = original_val # restore
        end
      end
      
      describe "number_of_two_bedroom_units_product" do
        it "should be nil when no units present" do
          @criterion_4.number_of_two_bedroom_units = nil
          @criterion_4.number_of_two_bedroom_units_product.should be nil
        end
        
        it "should be nil when no stat limit present" do
          @criterion_4.number_of_two_bedroom_units = 24
          original_val = Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms
          Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = nil
          @criterion_4.number_of_two_bedroom_units_product.should be nil
          Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = original_val # restore
        end
      end
      
      describe "number_of_three_bedroom_units_product" do
        it "should be nil when no units present" do
          @criterion_4.number_of_three_bedroom_units = nil
          @criterion_4.number_of_three_bedroom_units_product.should be nil
        end
        
        it "should be nil when no stat limit present" do
          @criterion_4.number_of_three_bedroom_units = 24
          original_val = Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms
          Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = nil
          @criterion_4.number_of_three_bedroom_units_product.should be nil
          Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = original_val # restore
        end
      end
      
      describe "number_of_four_or_more_bedroom_units_product" do
        it "should be nil when no units present" do
          @criterion_4.number_of_four_or_more_bedroom_units = nil
          @criterion_4.number_of_four_or_more_bedroom_units_product.should be nil
        end
        
        it "should be nil when no stat limit present" do
          @criterion_4.number_of_four_or_more_bedroom_units = 24
          original_val = Criterion4::StatutoryMortgageLimits.non_elevator_4_bedrooms
          Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = nil
          @criterion_4.number_of_four_or_more_bedroom_units_product.should be nil
          Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = original_val # restore
        end
      end
      
    end
    
    context "when numeric result expected" do
      
      before(:each) do
        @result = nil
        @expected = @criterion_4.high_cost_percentage.to_f/100
      end

      after(:each) { @result.should be_within(0.005).of(@expected)}
      
      describe "number_of_no_bedroom_units_product" do
        it "should be the product of number_of_no_bedroom_units, the base limit and high_cost_percentage" do
          @criterion_4.number_of_no_bedroom_units = @some_int
          @expected *= @some_int * Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms
          @result = @criterion_4.number_of_no_bedroom_units_product
        end
      end

      describe "number_of_one_bedroom_units_product" do
        it "should be the product of number_of_one_bedroom_units, the base limit and high_cost_percentage" do
          @criterion_4.number_of_one_bedroom_units = @some_int
          @expected *= @some_int * Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms
          @result = @criterion_4.number_of_one_bedroom_units_product
        end
      end

      describe "number_of_two_bedroom_units_product" do
        it "should be the product of number_of_two_bedroom_units, the base limit and high_cost_percentage" do
          @criterion_4.number_of_two_bedroom_units = @some_int
          @expected *= @some_int * Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms
          @result = @criterion_4.number_of_two_bedroom_units_product
        end
      end

      describe "number_of_three_bedroom_units_product" do
        it "should be the product of number_of_three_bedroom_units, the base limit and high_cost_percentage" do
          @criterion_4.number_of_three_bedroom_units = @some_int
          @expected *= @some_int * Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms
          @result = @criterion_4.number_of_three_bedroom_units_product
        end
      end

      describe "number_of_four_or_more_bedroom_units_product" do
        it "should be the product of number_of_four_or_more_bedroom_units, the base limit and high_cost_percentage" do
          @criterion_4.number_of_four_or_more_bedroom_units = @some_int
          @expected *= @some_int * Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms
          @result = @criterion_4.number_of_four_or_more_bedroom_units_product
        end
      end
    end
    
  end
  
  context "elevator project" do
    
    before(:each) do
      @criterion_4.is_elevator_project = true
      @result = nil
      @expected = @criterion_4.high_cost_percentage.to_f/100
    end
    
    after(:each) { @result.should be_within(0.005).of(@expected)}
    
    describe "number_of_no_bedroom_units_product" do
      it "should be the product of number_of_no_bedroom_units, the base limit and high_cost_percentage" do
        @criterion_4.number_of_no_bedroom_units = @some_int
        @expected *= @some_int * Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms
        @result = @criterion_4.number_of_no_bedroom_units_product
      end
    end
    
    describe "number_of_one_bedroom_units_product" do
      it "should be the product of number_of_one_bedroom_units, the base limit and high_cost_percentage" do
        @criterion_4.number_of_one_bedroom_units = @some_int
        @expected *= @some_int * Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms
        @result = @criterion_4.number_of_one_bedroom_units_product
      end
    end
    
    describe "number_of_two_bedroom_units_product" do
      it "should be the product of number_of_two_bedroom_units, the base limit and high_cost_percentage" do
        @criterion_4.number_of_two_bedroom_units = @some_int
        @expected *= @some_int * Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms
        @result = @criterion_4.number_of_two_bedroom_units_product
      end
    end
    
    describe "number_of_three_bedroom_units_product" do
      it "should be the product of number_of_three_bedroom_units, the base limit and high_cost_percentage" do
        @criterion_4.number_of_three_bedroom_units = @some_int
        @expected *= @some_int * Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms
        @result = @criterion_4.number_of_three_bedroom_units_product
      end
    end
    
    describe "number_of_four_or_more_bedroom_units_product" do
      it "should be the product of number_of_four_or_more_bedroom_units, the base limit and high_cost_percentage" do
        @criterion_4.number_of_four_or_more_bedroom_units = @some_int
        @expected *= @some_int * Criterion4::StatutoryMortgageLimits.elevator_4_plus_bedrooms
        @result = @criterion_4.number_of_four_or_more_bedroom_units_product
      end
    end
  end
  
  describe "line_b" do
    
    it "should be the product of cost_not_attributable_to_dwelling_use and percent_multiplier" do
      @criterion_4.percent_multiplier = pct = 85.0
      @criterion_4.cost_not_attributable_to_dwelling_use = cost = 400_000
      expected = pct/100 * cost
      @criterion_4.line_b.should be_within(0.005).of expected
    end
    
    it "should be nil when no cost_not_attributable_to_dwelling_use" do
      @criterion_4.cost_not_attributable_to_dwelling_use = nil
      @criterion_4.line_b.should be nil
    end
    
    it "should be nil when no percent_multiplier" do
      @criterion_4.percent_multiplier = nil
      @criterion_4.cost_not_attributable_to_dwelling_use = 400_000
      @criterion_4.line_b.should be nil
    end
  end
  
  describe "line_c" do
    it "should be the product of warranted_price_land and the percent_multiplier" do
      @criterion_4.warranted_price_of_land = @some_int
      expected = @some_int * @criterion_4.percent_multiplier.to_f/100
      @criterion_4.line_c.should be_within(0.005).of(expected)
    end
    
    it "should return nil if no warranted_price_of_land" do
      @criterion_4.warranted_price_of_land = nil
      @criterion_4.percent_multiplier = 86
      @criterion_4.line_c.should be nil
    end
    
    it "should return nil if no percent_multiplier" do
      @criterion_4.warranted_price_of_land = 400_000
      @criterion_4.percent_multiplier = nil
      @criterion_4.line_c.should be nil
    end
    
  end
  
  describe "line_d" do
    it "should be an alias for total_lines_a_through_c" do
      @criterion_4.should_receive(:number_of_one_bedroom_units_product).any_number_of_times.and_return(@some_int)
      @criterion_4.total_lines_a_through_c.should == @some_int
      @criterion_4.line_d.should == @criterion_4.total_lines_a_through_c
    end
  end
  
  describe "total_lines_a_through_c" do
    
    it "should be the sum of all line a items, line b and line c" do
      @criterion_4.should_receive(:number_of_no_bedroom_units_product).any_number_of_times.and_return(@some_int)
      @criterion_4.should_receive(:number_of_one_bedroom_units_product).and_return(@some_int)
      @criterion_4.should_receive(:number_of_two_bedroom_units_product).and_return(@some_int)
      @criterion_4.should_receive(:number_of_three_bedroom_units_product).and_return(@some_int)
      @criterion_4.should_receive(:number_of_four_or_more_bedroom_units_product).and_return(@some_int)
      @criterion_4.should_receive(:line_b).and_return(@some_int)
      @criterion_4.should_receive(:line_c).and_return(@some_int)
      expected = 7 * @some_int
      @criterion_4.total_lines_a_through_c.should == expected
    end
    
    it "should be the sum of any line a items" do
      @criterion_4.should_receive(:number_of_one_bedroom_units_product).any_number_of_times.and_return(@some_int)
      @criterion_4.total_lines_a_through_c.should == @some_int
    end
    
    it "should be nil when no values in lines a through c" do
      @criterion_4.should_receive(:number_of_no_bedroom_units_product).and_return nil
      @criterion_4.should_receive(:number_of_one_bedroom_units_product).and_return nil
      @criterion_4.should_receive(:number_of_two_bedroom_units_product).and_return nil
      @criterion_4.should_receive(:number_of_three_bedroom_units_product).and_return nil
      @criterion_4.should_receive(:number_of_four_or_more_bedroom_units_product).and_return nil
      @criterion_4.should_receive(:line_b).and_return nil
      @criterion_4.should_receive(:line_c).and_return nil
      @criterion_4.total_lines_a_through_c.should be nil
    end
    
  end
  
  describe "line_e" do
    it "should be the product of the high_cost_percentage, number of spaces and dollar limit per space" do
      @criterion_4.total_number_of_spaces = @some_int
      @criterion_4.high_cost_percentage = pct = 180.0
      expected = @some_int * pct/100 * Criterion4::StatutoryMortgageLimits.per_space
      @criterion_4.line_e.should be_within(0.005).of(expected)
    end
    
    it "should be nil when no spaces" do
      @criterion_4.total_number_of_spaces = nil
      @criterion_4.line_e.should be_nil
    end
    
    it "should be nil when no high cost percentage" do
      @criterion_4.high_cost_percentage = nil
      @criterion_4.line_e.should be_nil
    end
    
    it "should be nil when no per space stat limit" do
      original_val = Criterion4::StatutoryMortgageLimits.per_space
      Criterion4::StatutoryMortgageLimits.per_space = nil
      @criterion_4.total_number_of_spaces = 200
      @criterion_4.line_e.should be_nil
      Criterion4::StatutoryMortgageLimits.per_space = original_val
    end
  end
  
  describe "sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments" do
    it "should be the sum of both items" do
      @criterion_4.value_of_leased_fee = @some_int
      @criterion_4.unpaid_balance_of_special_assessments = @some_int
      expected = @some_int * 2
      @criterion_4.sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments.should == expected
    end
    
    it "should be value_of_leased_fee" do
      @criterion_4.value_of_leased_fee = @some_int
      @criterion_4.sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments.should == @some_int
    end
    
    it "should be unpaid_balance_of_special_assessments" do
      @criterion_4.unpaid_balance_of_special_assessments = @some_int
      @criterion_4.sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments.should == @some_int
    end
    
    it "should be nil when neither leased fee or unpaid balance of special assessments present" do
      @criterion_4.unpaid_balance_of_special_assessments = nil
      @criterion_4.value_of_leased_fee = nil
      @criterion_4.sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments.should be nil
    end
    
  end
  
  describe "line_f" do
    it "should be an alias for sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments" do
      @criterion_4.unpaid_balance_of_special_assessments = @some_int
      @criterion_4.sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments.should == @some_int
      @criterion_4.line_f.should == @some_int
    end
  end
  
  describe "line_d_or_line_e_minus_line_f" do
    it "should be line_d minus line_f" do
      line_d = @some_int * 2
      @criterion_4.should_receive(:line_d).and_return(line_d)
      @criterion_4.should_receive(:line_f).and_return(@some_int)
      expected = line_d - @some_int
      @criterion_4.line_d_or_line_e_minus_line_f.should == expected
    end
    
    it "should be line_e minus line_f" do
      line_e = @some_int * 2
      @criterion_4.should_receive(:line_e).and_return(line_e)
      @criterion_4.should_receive(:line_f).and_return(@some_int)
      expected = line_e - @some_int
      @criterion_4.line_d_or_line_e_minus_line_f.should == expected
    end
    
    it "should be nil when neither lines d or e present" do
      @criterion_4.should_receive(:line_e).and_return nil
      @criterion_4.should_receive(:line_d).and_return nil
      @criterion_4.line_d_or_line_e_minus_line_f.should be nil
    end
  end
  
  describe "line_g" do
    it "should be an alias for line_d_or_line_e_minus_line_f" do
      line_e = @some_int * 2
      @criterion_4.should_receive(:line_e).any_number_of_times.and_return(line_e)
      @criterion_4.should_receive(:line_f).any_number_of_times.and_return(@some_int)
      @criterion_4.line_d_or_line_e_minus_line_f.should == line_e - @some_int
      @criterion_4.line_g.should == @criterion_4.line_d_or_line_e_minus_line_f
    end
  end
  
end

describe Criterion4::Criterion4AcceptingCNAParameters do
  
  before(:each) do
    @attrs = {:high_cost_percentage=>270, :number_of_one_bedroom_units=>5, 
             :percent_multiplier=>85}
    @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs
  end
  
  it "should be instance of Criterion4::Criterion4" do
    (@criterion_4.is_a? Criterion4::Criterion4).should be true
  end
  
  describe "initialization" do
    it "should initialize cost_not_attributable_to_dwelling_use after initialization" do
      @attrs = {:high_cost_percentage=>270, :number_of_one_bedroom_units=>5, 
               :percent_multiplier=>85,:project_value=>10_000_000, :gross_apartment_square_feet=>10_000,
               :gross_other_square_feet=>1_000}
      @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs
      @criterion_4.cost_not_attributable_to_dwelling_use.should be > 0
    end
    
    it "should have all attributes that were initialized" do
      @attrs = {:high_cost_percentage=>270, :number_of_one_bedroom_units=>5, 
               :percent_multiplier=>85,:project_value=>10_000_000, :gross_apartment_square_feet=>10_000,
               :gross_other_square_feet=>1_000, :indoor_commercial_parking_square_feet=>5_000,
               :outdoor_commercial_parking_square_feet=>20_000}
      @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs
      @attrs.each {|k,v| @criterion_4.send(k).should == v }
    end
  end
  
  it "should be have criterion 4 attributes plus those of cna object, plus a cna attribute" do
    expected = Criterion4::Criterion4::ATTRIBUTES + Criterion4::CostNotAttributable::ATTRIBUTES + [:cna]
    expected.each {|k| @criterion_4.should respond_to k }
  end
  
  describe "validations" do
    
    it "should be invalid with every invalid attribute from cna" do
      invalid_attrs = {:outdoor_residential_parking_square_feet=>-1, 
                       :indoor_residential_parking_square_feet=>-1,
                       :outdoor_commercial_parking_square_feet=>-1, 
                       :indoor_commercial_parking_square_feet=>-1, 
                       :outdoor_parking_discount_percent=>-1, 
                       :gross_apartment_square_feet=>-1, :gross_other_square_feet=>-1, 
                       :gross_commercial_square_feet=>-1, :project_value=>-1}
      @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs.merge invalid_attrs
      @criterion_4.should_not be_valid
      invalid_attrs.keys.each{|k| @criterion_4.errors[k].should_not be_empty}
    end
    
    context "only either or none of cna attributes gross_apartment_square_feet and project_value provided" do

      it "should be valid when neither provided" do
        @criterion_4.should be_valid
      end
      
      it "should be valid when project_value not provided" do
        @attrs[:gross_apartment_square_feet] = 20_000
        @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs
        @criterion_4.should be_valid
      end
      
      it "should be valid when gross_apartment_square_feet not provided" do
        @attrs[:project_value] = 20_000_000
        @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs
        @criterion_4.should be_valid
      end
      
      it "should be invalid when gross_apartment_square_feet invalid" do
        @attrs[:gross_apartment_square_feet] = -20_000_000
        @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs
        @criterion_4.should_not be_valid
      end
      
      it "should be invalid when project_value invalid" do
        @attrs[:project_value] = -20_000_000
        @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs
        @criterion_4.should_not be_valid
      end
    end
    
    context "when cna attributes besides project value and gross apt square feet are present" do
      it "should be invalid when project value invalid" do
        min_valid_cna_attrs = {:gross_apartment_square_feet=>40_000, :project_value=> -10_000_000, 
                               :outdoor_residential_parking_square_feet=> 20_000}
        @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs.merge min_valid_cna_attrs
        @criterion_4.should_not be_valid
        @criterion_4.errors.size.should == 1
        @criterion_4.errors[:project_value].should == ['must be greater than or equal to 0']
      end
      
      it "should be invalid when gross_apartment_square_feet value invalid" do
        min_valid_cna_attrs = {:gross_apartment_square_feet=>-40_000, :project_value=> 10_000_000, 
                               :outdoor_residential_parking_square_feet=> 20_000}
        @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs.merge min_valid_cna_attrs
        @criterion_4.should_not be_valid
        @criterion_4.errors.size.should == 1
        @criterion_4.errors[:gross_apartment_square_feet].should == ['must be greater than or equal to 0']
      end
      
      it "should be invalid when project value absent" do
        min_cna_attrs = {:outdoor_residential_parking_square_feet=> 20_000}
        @criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new @attrs.merge min_cna_attrs
        @criterion_4.should_not be_valid
        @criterion_4.errors.size.should == 2
        @criterion_4.errors[:project_value].should == ['is not a number']
        @criterion_4.errors[:gross_apartment_square_feet].should == ['is not a number']
      end
      
    end
    
  end
  
end
