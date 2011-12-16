require 'spec_helper'

describe HighCostPercentage, "validations" do
  
  before(:each) {@hcp = HighCostPercentage.new :city=>"Aucklanc", :value=>0}
  
  specify {@hcp.should be_valid}
  
  context "invalid states" do
    
    after(:each) {@hcp.should_not be_valid}
    
    it "should not be valid when no city provided" do
      @hcp.city = nil
    end
    
    it "should not be valid when blank city provided" do
      @hcp.city = ''
    end
    
    it "should not be valid when no value provided" do
      @hcp.value = nil
    end
    
    it "should not be valid when value provided is non-integer" do
      @hcp.value = 1.1
    end
    
    it "should not be valid when value provided is negative" do
      @hcp.value = -1
    end
    
  end
end

describe HighCostPercentage do
  
  let(:some_val){120}
  let(:expected){some_val + 20}
  
  after(:all) {HighCostPercentage.delete_all}
  
  describe "#get_value" do
    it "should return the last value for 'no waiver' when more than one row in data store" do
      create_a_no_waiver_hcp_record some_val
      create_a_no_waiver_hcp_record expected
      HighCostPercentage.get_value('no waiver').should == expected
    end
    
    it "should return the last value for 'maximum waiver' when more than one row in data store" do
      create_a_max_waiver_hcp_record some_val
      create_a_max_waiver_hcp_record expected
      HighCostPercentage.get_value('maximum waiver').should == expected
    end
    
    it "should return the last value for 'standard waiver' when more than one row in data store" do
      create_a_standard_waiver_hcp_record some_val
      create_a_standard_waiver_hcp_record expected
      HighCostPercentage.get_value('standard waiver').should == expected
    end
    
    it "should return the last value for some location when more than one row in data store" do
      create_location_hcp_record "New York", "NY", some_val
      create_location_hcp_record "New York", "NY", expected
      HighCostPercentage.get_value('New York, NY').should == expected
    end
    
    it "should return nil when entity requested not found" do
      HighCostPercentage.delete_all
      HighCostPercentage.count.should == 0
      HighCostPercentage.get_value('Spartansburg, WK').should be nil
    end
    
  end
  
  private
  
  def create_a_no_waiver_hcp_record(val)
    create_hcp_record_without_state_abbreviation('no waiver', val)
  end
  
  def create_a_max_waiver_hcp_record(val)
    create_hcp_record_without_state_abbreviation('maximum waiver', val)
  end
  
  def create_a_standard_waiver_hcp_record(val)
    create_hcp_record_without_state_abbreviation('standard waiver', val)
  end
  
  def create_hcp_record_without_state_abbreviation(city, val)
    HighCostPercentage.create!(:city => city, :state_abbreviation => '', :value=>val,
                               :regional_office_city => '', :cbsa_code => '',
                               :regional_office_state_abbreviation => '')
  end
  
  def create_location_hcp_record(city, state, val)
    HighCostPercentage.create!(:city => city, :state_abbreviation => state, :value=>val,
                               :regional_office_city => '', :cbsa_code => '',
                               :regional_office_state_abbreviation => '')
  end
end
