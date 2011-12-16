require 'spec_helper'

describe ApiKey do
  
  let(:valid_value) {"gh34j7g91hsi234g"}
  
  describe "self.generate_key" do
    specify {ApiKey.generate_key.size.should == 16}
    specify {ApiKey.generate_key.should be_an_instance_of String}
  end
  
  describe "self.get_instance" do
    specify {(ApiKey.get_instance).should be_an_instance_of ApiKey}
    specify {(ApiKey.get_instance).should be_valid}
    specify {(ApiKey.get_instance).times_used.should == 0}
  end
  
  describe "#get_uses_remaining_and_increment_times_used_by_1" do
    
    before(:each) {@key = ApiKey.get_instance}
    
    it "should return uses currently remaining" do
      current_uses_remaining = @key.uses_remaining
      @key.get_uses_remaining_and_increment_times_used_by_1.should == current_uses_remaining
    end
    
    it "should increment times_used by 1" do
      previous_times_used = @key.times_used
      @key.get_uses_remaining_and_increment_times_used_by_1
      @key.times_used.should == previous_times_used + 1
    end
  end
  
  describe "#uses_remaining" do    
    it "should be the difference between maximum uses and times_used" do
      times_used = 13
      key = ApiKey.new(:times_used=>times_used, :value=>valid_value)
      key.uses_remaining.should == ApiKey::MAXIMUM_USAGE - times_used
    end
  end
  
  describe "#valid?" do
    
    let(:valid_attrs) {{:value=>valid_value, :times_used=>0}}
    
    it "should be true" do
      (ApiKey.new valid_attrs).should be_valid
    end
    
    it "should be false when a decimal" do
      (ApiKey.new valid_attrs.merge(:times_used=>32.56)).should_not be_valid
    end
    
    it "should be false when times_used < 0" do
      (ApiKey.new valid_attrs.merge(:times_used=>-1)).should_not be_valid
    end
    
    it "should be false when times_used > 50" do
      (ApiKey.new valid_attrs.merge(:times_used=>51)).should_not be_valid
    end
    
    it "should be false when times_used absent" do
      (ApiKey.new valid_attrs.merge(:times_used=>nil)).should_not be_valid
    end
    
    it "should be false when value length < 16" do
      valid_attrs[:value] = valid_value[0,14]
      (ApiKey.new valid_attrs).should_not be_valid
    end
    
    it "should be false when value absent" do
      (ApiKey.new valid_attrs.merge(:value=>nil)).should_not be_valid
    end
  end
  
end
