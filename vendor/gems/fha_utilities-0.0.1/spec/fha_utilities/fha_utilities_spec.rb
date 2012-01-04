require File.dirname(__FILE__) + "/../spec_helper.rb"

class TestClass
  include FhaUtilities::Lease
end

describe FhaUtilities::Lease do

  let(:valid_instance) do
    obj = TestClass.new
    obj.attributes = {:first_year_payment=>24, :term_in_years=>50,
                      :loan_interest_rate_percent=>7, :as_is_value_of_land_in_fee_simple=>1_000_000,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
    obj
  end
  
  describe "lease with level payments" do
    
    let(:threshold) do
      (valid_instance.as_is_value_of_land_in_fee_simple * 
       valid_instance.loan_interest_rate_percent.to_f/100).round(2)
    end
    
    it "should be valid when payments are a fn of the land value and the interest rate" do
      valid_instance.first_year_payment = threshold
      valid_instance.should be_valid
    end
    
    it "should be valid when payment_is_lump_sum_in_first_year is true" do
      valid_instance.first_year_payment = threshold + 1
      valid_instance.payment_is_lump_sum_in_first_year = true
      valid_instance.should be_valid
    end
    
    it "should not be valid when payments > a fn of the land value and the interest rate" do
      valid_instance.first_year_payment = threshold + 0.01
      valid_instance.should_not be_valid
      valid_instance.errors.size.should equal 1
      valid_instance.errors[:first_year_payment].should == ["is too high by 0.01"]
    end
  end
  
  describe "lease with variable payments" do
    
    let(:threshold) do
      (valid_instance.as_is_value_of_land_in_fee_simple * 
       valid_instance.loan_interest_rate_percent.to_f/100 * 0.9).round(2)
    end
    
    before {valid_instance.payments_are_variable = true}
    
    it "should be valid when payment is a fn of 0.9, the land value and the interest rate" do
      valid_instance.first_year_payment = threshold
      valid_instance.should be_valid
    end
    
    it "should be valid when payment_is_lump_sum_in_first_year is true" do
      valid_instance.first_year_payment = threshold + 1
      valid_instance.payment_is_lump_sum_in_first_year = true
      valid_instance.should be_valid
    end
    
    it "should not be valid when payment > a fn of 0.9, the land value and the interest rate" do
      valid_instance.first_year_payment = threshold + 0.01
      valid_instance.should_not be_valid
      valid_instance.errors.size.should equal 1
      valid_instance.errors[:first_year_payment].should == ["is too high by 0.01"]
    end
  end
  
  describe "attributes that must be greater than 0" do
    
    after(:each) do
      valid_instance.should_not be_valid
      valid_instance.errors.size.should equal 1
      valid_instance.errors[@attr_sym].should == ["must be greater than or equal to 0"]
    end
    
    it "should include first_year_payment" do
      valid_instance.first_year_payment = -1
      @attr_sym = :first_year_payment
    end
    
    it "should include term_in_years" do
      valid_instance.term_in_years= -1
      @attr_sym = :term_in_years
    end
    
    it "should include as_is_value_of_land_in_fee_simple" do
      valid_instance.as_is_value_of_land_in_fee_simple = -1
      @attr_sym = :as_is_value_of_land_in_fee_simple
    end
    
    it "should include loan_interest_rate_percent" do
      valid_instance.loan_interest_rate_percent = -1
      @attr_sym = :loan_interest_rate_percent
    end
    
    it "should include lease_capitalization_rate_percent" do
      valid_instance.lease_capitalization_rate_percent = -1
      @attr_sym = :lease_capitalization_rate_percent
    end
    
  end
  
  describe "attributes that are required" do
    
    after(:each) do
      valid_instance.should_not be_valid
      valid_instance.errors.size.should equal 1
      valid_instance.errors[@attr_sym].should == [@error_msg]
    end

    it "should include term_in_years_expresses_original_term_and_not_remaining_term" do
      valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = nil
      @attr_sym = :term_in_years_expresses_original_term_and_not_remaining_term
      @error_msg = "must be true or false"
    end

    it "should include as_is_value_of_land_in_fee_simple" do
      valid_instance.as_is_value_of_land_in_fee_simple = nil
      @attr_sym = :as_is_value_of_land_in_fee_simple
      @error_msg = "is not a number"
    end

    it "should include loan_interest_rate_percent" do
      valid_instance.loan_interest_rate_percent = nil
      @attr_sym = :loan_interest_rate_percent
      @error_msg = "is not a number"
    end

    it "should include first_year_payment" do
      valid_instance.first_year_payment = nil
      @attr_sym = :first_year_payment
      @error_msg = "is not a number"
    end
    
    it "should include term_in_years" do
      valid_instance.term_in_years = nil
      @attr_sym = :term_in_years
      @error_msg = "is not a number"
    end
    
    it "should include has_option_to_buy" do
      valid_instance.has_option_to_buy = nil
      @attr_sym = :has_option_to_buy
      @error_msg = "must be true or false"
    end
    
    it "should include payments_are_variable" do
      valid_instance.payments_are_variable = nil
      @attr_sym = :payments_are_variable
      @error_msg = "must be true or false"
    end
    
    it "should include payment_is_lump_sum_in_first_year" do
      valid_instance.payment_is_lump_sum_in_first_year = nil
      @attr_sym = :payment_is_lump_sum_in_first_year
      @error_msg = "must be true or false"
    end
    
    context "when term_in_years_expresses_original_term_and_not_remaining_term is true" do
      it "should include is_renewable" do
        valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = true
        valid_instance.is_renewable = nil
        @attr_sym = :is_renewable
        @error_msg = "can't be blank when term_in_years_expresses_original_term_and_not_remaining_term is true"
      end
    end
    
  end
  
  describe "attributes that must be equal to or less than 100" do
    
    after(:each) do
      valid_instance.should_not be_valid
      valid_instance.errors.size.should equal 1
      valid_instance.errors[@attr_sym].should == ["must be less than or equal to 100"]
    end
    
    it "should include loan_interest_rate_percent" do
      valid_instance.loan_interest_rate_percent = 100.01
      @attr_sym = :loan_interest_rate_percent
    end
    
    it "should include lease_capitalization_rate_percent" do
      valid_instance.lease_capitalization_rate_percent = 100.01
      @attr_sym = :lease_capitalization_rate_percent
    end
    
  end
  
  describe "attributes that must be false" do
    context "when has_option_to_buy is true" do
      it "should include payments_are_variable" do
        valid_instance.has_option_to_buy = true
        valid_instance.payments_are_variable = true
        valid_instance.should_not be_valid
        valid_instance.errors.size.should equal 1
        msg = "must be false when has_option_to_buy is true"
        valid_instance.errors[:payments_are_variable].should == [msg]
      end
    end
  end
  
  describe "attributes that must be true or false" do
    
    let(:invalid_attribute) {"invalid attribute"}
    
    after(:each) do
      valid_instance.should_not be_valid
      valid_instance.errors.size.should equal 1
      valid_instance.errors[@attr_sym].should == ["must be true or false"]
    end
    
    it "should include #has_option_to_buy" do
      valid_instance.has_option_to_buy = invalid_attribute
      @attr_sym = :has_option_to_buy
    end
    
    it "should include term_in_years_expresses_original_term_and_not_remaining_term" do
      valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = invalid_attribute
      @attr_sym = :term_in_years_expresses_original_term_and_not_remaining_term
    end
    
    it "should include #payments_are_variable" do
      valid_instance.payments_are_variable = invalid_attribute
      @attr_sym = :payments_are_variable
    end
    
    it "should include #is_renewable" do
      valid_instance.is_renewable = invalid_attribute
      @attr_sym = :is_renewable
    end
    
    it "should include #payment_is_lump_sum_in_first_year" do
      valid_instance.payment_is_lump_sum_in_first_year = invalid_attribute
      @attr_sym = :payment_is_lump_sum_in_first_year
    end
  end
  
  describe "value_of_the_leased_fee" do
    context "when has_option_to_buy is false" do
      it "should be as_is_value_of_land_in_fee_simple" do
        valid_instance.has_option_to_buy = false
        valid_instance.lease_capitalization_rate_percent = 6
        expected = valid_instance.as_is_value_of_land_in_fee_simple
        valid_instance.value_of_the_leased_fee.should be_within(0.005).of expected
      end
    end
    
    context "when lease_capitalization_rate_percent is nil" do
      it "should be as_is_value_of_land_in_fee_simple" do
        valid_instance.has_option_to_buy = true
        valid_instance.lease_capitalization_rate_percent = nil
        expected = valid_instance.as_is_value_of_land_in_fee_simple
        valid_instance.value_of_the_leased_fee.should be_within(0.005).of expected
      end
    end
    
    context "when lease_capitalization_rate_percent is present and has_option_to_buy" do
      it "should be the capitalized lease value" do
        valid_instance.first_year_payment = 100_000
        valid_instance.has_option_to_buy = true
        valid_instance.lease_capitalization_rate_percent = 5.0
        expected = valid_instance.first_year_payment/(valid_instance.lease_capitalization_rate_percent/100)
        valid_instance.value_of_the_leased_fee.should be_within(0.005).of expected
      end
    end
  end
  
end

class TestClass2
  include FhaUtilities::Lease::Sec207223f
end

describe FhaUtilities::Lease::Sec207223f do
  
  let(:valid_instance) do
    obj = TestClass2.new
    obj.attributes = {:first_year_payment=>24, :term_in_years=>50,
                      :loan_interest_rate_percent=>7, :as_is_value_of_land_in_fee_simple=>1_000_000,
                      :term_in_years_expresses_original_term_and_not_remaining_term => false,
                      :has_option_to_buy=>false, :payments_are_variable=>false, :is_renewable=>false,
                      :payment_is_lump_sum_in_first_year=>false}
    obj
  end
  
  it "should extend FhaUtilities::Lease" do
    valid_instance.should be_a_kind_of FhaUtilities::Lease
  end
  
  context "when term_in_years_expresses_original_term_and_not_remaining_term is false" do
    context "and term_in_years is less than 50" do
      it "should not be valid" do
        valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = false
        valid_instance.term_in_years = 49
        valid_instance.should_not be_valid
        valid_instance.errors.size.should equal 1
        msg = "can't be less than 50 when expressing the remaining lease term"
        valid_instance.errors[:term_in_years].should == [msg]
      end
    end
  end
  
  context "term_in_years_expresses_original_term_and_not_remaining_term is true" do
    context "and term_in_years is less than 99" do
      it "should not be valid" do
        valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = true
        valid_instance.term_in_years = 98
        valid_instance.should_not be_valid
        valid_instance.errors.size.should equal 1
        msg = "can't be less than 99 when expressing the original lease term"
        valid_instance.errors[:term_in_years].should == [msg]
      end
    end
    
    context "and term_in_years is greater than or equal to 99, but is_renewable is false" do
      it "should not be valid" do
        valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = true
        valid_instance.term_in_years = 99
        valid_instance.is_renewable = false
        valid_instance.should_not be_valid
        valid_instance.errors.size.should equal 1
        msg = "can't be false if original lease term is 99 years or greater"
        valid_instance.errors[:is_renewable].should == [msg]
      end
    end
  end
  
end

shared_examples_for "any lease for a non-Sec.207/223f loan" do
  
  let(:valid_instance) do
    implementing_class.new({:first_year_payment=>24, :term_in_years=>50, 
                            :mortgage_term_in_years => 30, :is_renewable=>false,
                            :loan_interest_rate_percent=>7, 
                            :as_is_value_of_land_in_fee_simple=>1_000_000,
                            :term_in_years_expresses_original_term_and_not_remaining_term => false,
                            :has_option_to_buy=>false, :payments_are_variable=>false,
                            :payment_is_lump_sum_in_first_year=>false})
  end
  
  it "should extend FhaUtilities::Lease" do
    valid_instance.should be_a_kind_of FhaUtilities::Lease
  end
  
  it "should not be valid when mortgage_term_in_years is absent" do
    valid_instance.mortgage_term_in_years = nil
    valid_instance.should_not be_valid
    valid_instance.errors.size.should equal 1
    valid_instance.errors[:mortgage_term_in_years].should == ["is not a number"]
  end
  
  it "should not be valid when mortgage_term_in_years is negative" do
    valid_instance.mortgage_term_in_years = -1
    valid_instance.should_not be_valid
    valid_instance.errors.size.should equal 1
    valid_instance.errors[:mortgage_term_in_years].should == ["must be greater than or equal to 0"]
  end
  
  context "when term_in_years_expresses_original_term_and_not_remaining_term is false" do
    context "and term_in_years is less than mortgage_term_in_years + 10" do
      it "should not be valid" do
        valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = false
        valid_instance.term_in_years = 44
        valid_instance.mortgage_term_in_years = 35
        valid_instance.should_not be_valid
        valid_instance.errors.size.should equal 1
        msg = "can't be less than the mortgage term in years plus 10"
        valid_instance.errors[:term_in_years].should == [msg]
      end
    end
  end
  
  context "term_in_years_expresses_original_term_and_not_remaining_term is true" do
    context "and term_in_years is less than 99" do
      it "should not be valid" do
        valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = true
        valid_instance.term_in_years = 98
        valid_instance.should_not be_valid
        valid_instance.errors.size.should equal 1
        msg = "can't be less than 99 when expressing the original lease term"
        valid_instance.errors[:term_in_years].should == [msg]
      end
    end
  
    context "and term_in_years is greater than or equal to 99, but is_renewable is false" do
      it "should not be valid" do
        valid_instance.term_in_years_expresses_original_term_and_not_remaining_term = true
        valid_instance.term_in_years = 99
        valid_instance.is_renewable = false
        valid_instance.should_not be_valid
        valid_instance.errors.size.should equal 1
        msg = "can't be false if original lease term is 99 years or greater"
        valid_instance.errors[:is_renewable].should == [msg]
      end
    end
  end
end

describe FhaUtilities::Lease::Sec220 do
  
  let(:implementing_class) {class TestClass3; include FhaUtilities::Lease::Sec220; end}
  
  it_should_behave_like "any lease for a non-Sec.207/223f loan"
  
end

describe FhaUtilities::Lease::Sec221d do

  let(:implementing_class) {class TestClass4; include FhaUtilities::Lease::Sec221d; end}
  
  it_should_behave_like "any lease for a non-Sec.207/223f loan"
  
end

describe FhaUtilities::Lease::Sec232 do
  
  let(:implementing_class) {class TestClass5; include FhaUtilities::Lease::Sec232; end}
  
  it_should_behave_like "any lease for a non-Sec.207/223f loan"
  
end