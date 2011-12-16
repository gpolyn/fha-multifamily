require 'spec_helper'

describe SelectSec223fValidations do
  
  before(:each) do
    class TestImpl; include SelectSec223fValidations; end
    @test_obj = TestImpl.new(:affordability=>"some string", 
                             :metropolitan_area_waiver=>"some other string", 
                             :annual_replacement_reserve_per_unit=>250)
  end
  
  it "should be valid" do
    @test_obj.should be_valid
  end
  
  describe "validations" do
    
    after(:each) {@test_obj.should_not be_valid}
    
    describe "affordability" do
      it "should not be valid when string is zero-length" do
        @test_obj.affordability = ""
      end

      it "should not be valid when missing" do
        @test_obj.affordability = nil
      end

      it "should not be valid when not a string" do
        @test_obj.affordability = 123
      end
    end
    
    describe "metropolitan_area_waiver" do
      it "should not be valid when string is zero-length" do
        @test_obj.metropolitan_area_waiver = ""
      end

      it "should not be valid when missing" do
        @test_obj.metropolitan_area_waiver = nil
      end

      it "should not be valid when not a string" do
        @test_obj.metropolitan_area_waiver = 123
      end
    end
    
    describe "annual_replacement_reserve_per_unit" do
      it "should not be valid when < 250" do
        @test_obj.annual_replacement_reserve_per_unit = 249.99
      end

      it "should not be valid when missing" do
        @test_obj.annual_replacement_reserve_per_unit = nil
      end
    end
    
  end
  
end