require File.dirname(__FILE__) + "/../spec_helper.rb"

shared_examples_for "any tax abatement phase" do
  
  after do
    valid_instance.should_not be_valid
    valid_instance.errors.size.should == 1
    valid_instance.errors[@attr_sym].should == [@msg]
  end
  
  describe "attributes that must be greater than or equal to 0" do
    
    before {@msg = "must be greater than or equal to 0"}
    
    it "should include end_year" do
      valid_instance.end_year = -1
      @attr_sym = :end_year
    end
    
    it "should include annual_amount" do
      valid_instance.annual_amount = -1
      @attr_sym = :annual_amount
    end
    
  end
  
  describe "attributes that are required" do
    
    before {@msg = "is not a number"}
    
    it "should include end_year" do
      valid_instance.end_year = nil
      @attr_sym = :end_year
    end
    
    it "should include annual_amount" do
      valid_instance.annual_amount = nil
      @attr_sym = :annual_amount
    end
    
  end
  
  describe "attributes that must be integers" do

    it "should include end_year" do
      valid_instance.end_year = 1999.1
      @attr_sym = :end_year
      @msg = "must be an integer"
    end
    
  end
  
end

shared_examples_for "only some tax abatement phases" do
  
  after do
    valid_instance.should_not be_valid
    valid_instance.errors.size.should == 1
    valid_instance.errors[@attr_sym].should == [@msg]
  end
  
  describe "attributes that must be greater than or equal to 0" do
    it "should include start_year" do
      valid_instance.start_year = -1
      @attr_sym = :start_year
      @msg = "must be greater than or equal to 0"
    end
  end
  
  describe "attributes that are required" do
    it "should include start_year" do
      valid_instance.start_year = nil
      @attr_sym = :start_year
      @msg = "is not a number"
    end
  end
  
  describe "attributes that must be integers" do
    it "should include start_year" do
      valid_instance.start_year = 1.1
      @attr_sym = :start_year
      @msg = "must be an integer"
    end
  end
  
  describe "end_year" do
    it "must be greater than start_year" do
      valid_instance.end_year = valid_instance.start_year
      @attr_sym = :end_year
      @msg = "must be greater than 1999"
    end
  end
  
end

shared_examples_for "any tax abatement" do
  
  describe "attributes that are required" do
    
    after do
      valid_instance.should_not be_valid
      valid_instance.errors.size.should == 1
      valid_instance.errors[@attr_sym].should == ["is not a number"]
    end
    
    it "should include loan_term_in_months" do
      valid_instance.loan_term_in_months = nil
      @attr_sym = :loan_term_in_months
    end
    
    it "should include mortgage_interest_rate_percent" do
      valid_instance.mortgage_interest_rate_percent = nil
      @attr_sym = :mortgage_interest_rate_percent
    end
    
    it "should include mortgage_insurance_premium_percent" do
      valid_instance.mortgage_insurance_premium_percent = nil
      @attr_sym = :mortgage_insurance_premium_percent
    end
  end
  
  describe "attributes that must be greater than or equal to 0" do
    
    after do
      valid_instance.should_not be_valid
      valid_instance.errors.size.should == 1
      valid_instance.errors[@attr_sym].should == ["must be greater than or equal to 0"]
    end
    
    it "should include loan_term_in_months" do
      valid_instance.loan_term_in_months = -1
      @attr_sym = :loan_term_in_months
    end
    
    it "should include mortgage_interest_rate_percent" do
      valid_instance.mortgage_interest_rate_percent = -1
      @attr_sym = :mortgage_interest_rate_percent
    end
    
    it "should include mortgage_insurance_premium_percent" do
      valid_instance.mortgage_insurance_premium_percent = -1
      @attr_sym = :mortgage_insurance_premium_percent
    end
  end
  
  describe "attributes that must be less than or equal to 100" do
    
    after do
      valid_instance.should_not be_valid
      valid_instance.errors.size.should == 1
      valid_instance.errors[@attr_sym].should == ["must be less than or equal to 100"]
    end
    
    it "should include mortgage_interest_rate_percent" do
      valid_instance.mortgage_interest_rate_percent = 101
      @attr_sym = :mortgage_interest_rate_percent
    end
    
    it "should include mortgage_insurance_premium_percent" do
      valid_instance.mortgage_insurance_premium_percent = 101
      @attr_sym = :mortgage_insurance_premium_percent
    end
  end
  
  describe "attributes that must be only integers" do
    it "should include loan_term_in_months" do
      valid_instance.loan_term_in_months = 24.5
      valid_instance.should_not be_valid
      valid_instance.errors.size.should == 1
      valid_instance.errors[:loan_term_in_months].should == ["must be an integer"]
    end
  end
end

class FixedTaxAbatementTestClass
  include FhaUtilities::TaxAbatement::Fixed
end

describe FhaUtilities::TaxAbatement::Fixed do
  
  let(:valid_instance) do
    attrs = {:end_year=>2001, :annual_amount=>5_000,
             :mortgage_insurance_premium_percent=>0.5, :loan_term_in_months=>35*12,
             :mortgage_interest_rate_percent=>7.5}
    FixedTaxAbatementTestClass.new attrs
  end
  
  it_should_behave_like "any tax abatement phase"
  it_should_behave_like "any tax abatement"
  
  describe "start_year" do
    
    it "should not change with setter" do
      valid_instance.start_year = 2
      valid_instance.start_year.should == 0
    end
    
    specify {valid_instance.start_year.should == 0}
    
  end
  
  describe "present_value" do

    it "should be 0 when lease length is greater than mortgage term" do
      valid_instance.end_year = 36
      valid_instance.present_value.should == 0
    end

    it "should be 0 when lease length equals mortgage term" do
      valid_instance.end_year = 35
      valid_instance.present_value.should == 0
    end
    
    it "should be have expected positive value when lease length is less than mortgage term" do
      valid_instance.end_year = 5
      valid_instance.present_value.should be_within(0.005).of 20_370.30
    end
    
  end
  
end

class VariableTaxAbatementTestClass
  include FhaUtilities::TaxAbatement::Variable
end

describe "a FhaUtilities::TaxAbatement::Variable phase" do
  
  let(:valid_instance) do
    attrs = {:variable_phase_1=>{:start_year=>1999, :end_year=>2001, :annual_amount=>50_000}}
    (VariableTaxAbatementTestClass.new attrs).variable_phase_1
  end
  
  it_should_behave_like "any tax abatement phase"
  it_should_behave_like "only some tax abatement phases"
  
end

describe FhaUtilities::TaxAbatement::Variable do
  
  let(:valid_instance) do
    attrs = {:variable_phase_1=>{:start_year=>1999, :end_year=>2001, :annual_amount=>50_000},
             :mortgage_insurance_premium_percent=>0.5, :loan_term_in_months=>35*12,
             :mortgage_interest_rate_percent=>7.5}
    VariableTaxAbatementTestClass.new attrs
  end
  
  it_should_behave_like "any tax abatement"
  
  it "should not be valid when any phase is invalid" do
    valid_instance.variable_phase_2 = {:start_year=>2001, :end_year=>2001, :annual_amount=>50_000}
    valid_instance.should_not be_valid
    valid_instance.errors[:variable_phase_2].should == ["end year must be greater than 2001"]
  end
  
  it "should respond to method calls of pattern 'variable_phase_(\\d+)='" do
    valid_instance.should respond_to :variable_phase_34=
  end
  
  it "should respond to method calls of pattern 'variable_phase_(\\d+)'" do
    valid_instance.should respond_to :variable_phase_34
  end
  
  it "should not be valid when any phases overlap (and regardless of phase label number)" do
    valid_instance.variable_phase_4 = {:start_year=>2007, :end_year=>2009, :annual_amount=>2_000}
    valid_instance.variable_phase_2 = {:start_year=>2004, :end_year=>2008, :annual_amount=>5_000}
    valid_instance.variable_phase_3 = {:start_year=>2000, :end_year=>2004, :annual_amount=>7_000}
    valid_instance.should_not be_valid
    valid_instance.errors.size.should == 2
    msg = "must not start before end of variable phase 1"
    valid_instance.errors[:variable_phase_3].should == [msg]
    msg = "must not start before end of variable phase 2"
    valid_instance.errors[:variable_phase_4].should == [msg]
  end
  
  it "should not raise error validating when phase arguments are missing" do
    valid_instance.variable_phase_2 = {:end_year=>2008, :annual_amount=>5_000}
    valid_instance.variable_phase_3 = {:start_year=>2000, :annual_amount=>7_000}
    lambda {valid_instance.should_not be_valid}.should_not raise_error
  end
  
  describe "present_value" do
    it "should be expected positive value" do
      attrs = {:variable_phase_1=>{:start_year=>10, :end_year=>15, :annual_amount=>5_000},
               :variable_phase_2=>{:start_year=> 0, :end_year=>5, :annual_amount=>25_000},
               :variable_phase_3=>{:start_year=>5, :end_year=>10, :annual_amount=>10_000},
               :mortgage_insurance_premium_percent=>0.5, :loan_term_in_months=>35*12,
               :mortgage_interest_rate_percent=>7.5}
      instance = VariableTaxAbatementTestClass.new attrs
      instance.present_value.should be_within(1.0).of 138_037
    end
  end
  
  describe "adding another dynamic attribute of the same name" do
    it "should completely replace the prior dynamic attribute" do
      valid_instance.variable_phase_1.start_year=10
      valid_instance.variable_phase_1.end_year=15
      valid_instance.variable_phase_1.annual_amount = 5_000
      valid_instance.variable_phase_2 = {:start_year=> 0, :end_year=>5, :annual_amount=>25_000}
      valid_instance.variable_phase_3 = {:start_year=>5, :end_year=>10, :annual_amount=>10_000}
      valid_instance.present_value.should be_within(1.0).of 138_037
    end
  end
  
end

describe FhaUtilities::TaxAbatement::Variable::Phase do
  it "should allow replacement in a set on the basis of equal attribute_sym_name attributes" do
    set = SortedSet.new
    set << FhaUtilities::TaxAbatement::Variable::Phase.new(:start_year=>10, :end_year=>15, :attribute_sym_name=>:go)
    set << FhaUtilities::TaxAbatement::Variable::Phase.new(:start_year=>0, :end_year=>5, :attribute_sym_name=>:go)
    set.size.should == 1
  end
end
