require File.dirname(__FILE__) + "/../spec_helper.rb"

class TestClass
  include Hud92264::A3::TotalRequirementsForSettlement::PartB 
  attr_accessor :transaction_amount_including_loan_closing_charges, :required_repairs, 
                :initial_operating_deficit, :mortgage_amount, :grant_or_loan, 
                :replacement_reserve, :major_movable_equipment
end

describe Hud92264::A3::TotalRequirementsForSettlement::PartB do
  
  it_behaves_like "Hud92264::A3::TotalRequirementsForSettlement::PartB" do
    let(:host){TestClass.new}
  end
  
  describe "derived attributes" do
    
    let(:host) {TestClass.new}
    let(:some_int) {10_000_000}
    
    describe "lines_4a_plus_4b_plus_5" do
      it "should be nil when neither line_4_a or line_4_b" do
        host.line_4_a.should be nil
        host.line_4_b.should be nil
        host.lines_4a_plus_4b_plus_5.should be nil
      end
      
      it "should be line_4_a when no line_4_b" do
        host.mortgage_amount = some_int
        host.line_4_b.should be nil
        host.lines_4a_plus_4b_plus_5.should == some_int
      end
      
      it "should be line_4_b when no line_4_a" do
        host.line_4_a.should be nil
        expected = host.grant_or_loan = 245
        expected += host.replacement_reserve = 1235
        expected += host.major_movable_equipment = 256
        host.lines_4a_plus_4b_plus_5.should == expected
      end
      
      it "should be line_4_b + line_4_a, when both present" do
        expected = host.mortgage_amount = some_int
        expected += host.grant_or_loan = 245
        expected += host.replacement_reserve = 1235
        expected += host.major_movable_equipment = 256
        host.lines_4a_plus_4b_plus_5.should == expected
      end
    end

    describe "grant_or_loan_and_replacement_reserve_and_major_movable_equipment" do
      it "should be nil when none of grant_or_loan, replacement_reserve or major_movable_equipment" do
        host.grant_or_loan.should be nil
        host.replacement_reserve.should be nil
        host.major_movable_equipment.should be nil
        host.grant_or_loan_and_replacement_reserve_and_major_movable_equipment.should be nil
      end

      it "should be major_movable_equipment when neither grant_or_loan or replacement_reserve" do
        host.grant_or_loan.should be nil
        host.replacement_reserve.should be nil
        host.major_movable_equipment = some_int
        host.grant_or_loan_and_replacement_reserve_and_major_movable_equipment.should == some_int
      end

      it "should be replacement_reserve when neither grant_or_loan or major_movable_equipment" do
        host.grant_or_loan.should be nil
        host.replacement_reserve = some_int
        host.major_movable_equipment.should be nil
        host.grant_or_loan_and_replacement_reserve_and_major_movable_equipment.should == some_int
      end

      it "should be grant_or_loan, when neither replacement_reserve or major_movable_equipment" do
        host.grant_or_loan = some_int
        host.replacement_reserve.should be nil
        host.major_movable_equipment.should be nil
        host.grant_or_loan_and_replacement_reserve_and_major_movable_equipment.should == some_int
      end

      it "should be grant_or_loan, replacement_reserve and major_movable_equipment" do
        expected = host.grant_or_loan = 123
        expected += host.replacement_reserve = 3265
        expected += host.major_movable_equipment = 8998
        host.grant_or_loan_and_replacement_reserve_and_major_movable_equipment.should == expected
      end
    end

    describe "line_3" do
      it "should be nil if neither line_1_c or line_2" do
        host.line_1_c.should be nil
        host.line_2.should be nil
        host.line_3.should nil
      end

      it "should be line_1_c when no line_2" do
        host.transaction_amount_including_loan_closing_charges = some_int
        host.line_2.should be nil
        host.line_3.should == some_int
      end

      it "should be line_2 when no line_1_c" do
        host.line_1_c.should be nil
        host.required_repairs = some_int
        host.line_3.should == some_int
      end
    end
  
    describe "cash_investment_required" do
      it "should be nil when neither line_3 or line_6" do
        host.line_3.should be nil
        host.line_6.should be nil
        host.cash_investment_required.should be nil
      end
      
      it "should be nil when line_3 but not line_6" do
        host.transaction_amount_including_loan_closing_charges = some_int
        host.line_6.should be nil
        host.cash_investment_required.should be nil
      end
      
      it "should be nil when line_6 but not line_3" do
        host.line_3.should be nil
        host.mortgage_amount = some_int
        host.cash_investment_required.should be nil
      end
      
      it "should be line_3 - line_6" do
        host.transaction_amount_including_loan_closing_charges = some_int * 2
        host.mortgage_amount = some_int
        host.cash_investment_required.should == some_int
      end
    end
    
    describe "total_estimated_cash_requirement" do
      it "should be nil when neither line_7 or line_8" do
        host.line_7.should be nil
        host.line_8.should be nil
        host.total_estimated_cash_requirement.should be nil
      end
      
      it "should be line_7 when no line_8" do
        host.transaction_amount_including_loan_closing_charges = some_int * 2
        host.mortgage_amount = some_int
        host.line_8.should be nil
        host.total_estimated_cash_requirement.should == some_int
      end
      
      it "should be line_8 when no line_7" do
        host.line_7.should be nil
        host.initial_operating_deficit = some_int
        host.total_estimated_cash_requirement.should == some_int
      end
      
      it "should be line_7 + line_8" do
        host.transaction_amount_including_loan_closing_charges = some_int * 2
        host.mortgage_amount = some_int
        host.initial_operating_deficit = some_int
        host.total_estimated_cash_requirement.should == some_int * 2
      end
    end
    
  end
end