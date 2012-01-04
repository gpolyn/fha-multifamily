require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Criterion4" do
  it "has a version" do
    Criterion4::VERSION.should == "0.0.1"
  end
end

describe "Criterion4::StatutoryMortgageLimits" do
  
  describe "per_space" do
    it "should be as set" do
      Criterion4::StatutoryMortgageLimits.per_space = expected = 20_000
      Criterion4::StatutoryMortgageLimits.per_space.should == expected
    end
  end
  
  context "non-elevator limits" do
    
    before(:all) do
      Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms = @non_elevator_0_bedrooms = 1
      Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms = @non_elevator_1_bedrooms = 2
      Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms = @non_elevator_2_bedrooms = 3
      Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms = @non_elevator_3_bedrooms = 4
      Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms = @non_elevator_4_plus_bedrooms = 5
    end
    
    specify {Criterion4::StatutoryMortgageLimits.non_elevator_0_bedrooms.should == @non_elevator_0_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.non_elevator_1_bedrooms.should == @non_elevator_1_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.non_elevator_2_bedrooms.should == @non_elevator_2_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.non_elevator_3_bedrooms.should == @non_elevator_3_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms.should == @non_elevator_4_plus_bedrooms}
    
    describe "non_elevator_4_bedrooms" do
      it "should be an alias for non_elevator_4_plus_bedrooms" do
        expected = Criterion4::StatutoryMortgageLimits.non_elevator_4_plus_bedrooms
        Criterion4::StatutoryMortgageLimits.non_elevator_4_bedrooms.should == expected
      end
    end
    
  end
  
  context "elevator limits" do
    
    before(:all) do
      Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms = @elevator_0_bedrooms = 1
      Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms = @elevator_1_bedrooms = 2
      Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms = @elevator_2_bedrooms = 3
      Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms = @elevator_3_bedrooms = 4
      Criterion4::StatutoryMortgageLimits.elevator_4_plus_bedrooms = @elevator_4_plus_bedrooms = 5
    end
    
    specify {Criterion4::StatutoryMortgageLimits.elevator_0_bedrooms.should == @elevator_0_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.elevator_1_bedrooms.should == @elevator_1_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.elevator_2_bedrooms.should == @elevator_2_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.elevator_3_bedrooms.should == @elevator_3_bedrooms}
    specify {Criterion4::StatutoryMortgageLimits.elevator_4_plus_bedrooms.should == @elevator_4_plus_bedrooms}
    
    describe "elevator_4_bedrooms" do
      it "should be an alias for elevator_4_plus_bedrooms" do
        expected = Criterion4::StatutoryMortgageLimits.elevator_4_plus_bedrooms
        Criterion4::StatutoryMortgageLimits.elevator_4_bedrooms.should == expected
      end
    end
    
  end
  
end