require File.dirname(__FILE__) + "/../spec_helper.rb"

class TransactionCostCriterionClass
  attr_accessor :fha_inspection_fee, 
                :third_party_reports, :other, :survey, 
                :replacement_reserves_on_deposit, :major_movable_equipment,
                :initial_deposit_to_replacement_reserve, 
                :title_and_recording_is_percent_of_loan, 
                :financing_fee_is_percent_of_loan, :legal_and_organizational,
                :title_and_recording, :financing_fee,
                :first_year_mortgage_insurance_premium_rate, :exam_fee_rate, 
                :discounts_rate, :permanent_placement_rate
end

class ImplementingClass
  
  include Sec223fCashRequirement
  
  def initialize(trans_cost_class)
    self.transaction_cost_criterion = trans_cost_class
  end
  
  attr_accessor :mortgage_amount, :estimate_of_repair_cost
  
end

describe Sec223fCashRequirement do
  
  let(:transaction_cost_criterion) {TransactionCostCriterionClass.new}
  let(:implementing_class) {ImplementingClass.new(transaction_cost_criterion)}
  let(:some_int) {1234}
  
  it_behaves_like "Hud92264::A3::TotalRequirementsForSettlement::PartB" do
    let(:host){implementing_class}
  end
  
  it_behaves_like "Hud92013::Attachments::DevelopmentCosts" do
    let(:host){implementing_class}
  end
  
  describe "#estimate_of_repair_cost" do
    context "when not implemented in host" do
      it "should raise NotImplementedError" do
        object = Object.new
        object.extend(Sec223fCashRequirement)
        lambda {object.estimate_of_repair_cost}.should raise_error NotImplementedError
      end
    end
    
    context "when implemented in host" do
      it "should not raise NotImplementedError" do
        object = double('host', :estimate_of_repair_cost=>some_int)
        object.extend(Sec223fCashRequirement)
        lambda {object.estimate_of_repair_cost}.should_not raise_error NotImplementedError
      end
    end
  end
  
  describe "#mortgage_amount" do
    context "when not implemented in host" do
      it "should raise NotImplementedError" do
        object = Object.new
        object.extend(Sec223fCashRequirement)
        lambda {object.mortgage_amount}.should raise_error NotImplementedError
      end
    end
    
    context "when implemented in host" do
      it "should not raise NotImplementedError" do
        object = double('host', :mortgage_amount=>some_int)
        object.extend(Sec223fCashRequirement)
        lambda {object.mortgage_amount}.should_not raise_error NotImplementedError
      end
    end
  end
  
  describe "#initial_deposit_to_reserve_fund" do
    it "should be initialized value" do
      transaction_cost_criterion.initial_deposit_to_replacement_reserve = some_int
      implementing_class.initial_deposit_to_reserve_fund.should == some_int
    end
  end
  
  describe "#fha_inspection_fee" do
    it "should be the initialized value" do
      transaction_cost_criterion.fha_inspection_fee = some_int
      implementing_class.fha_inspection_fee.should == some_int
    end
  end
  
  describe "#financing_fee" do
    
    it "should be financing_fee when financing_fee_is_percent_of_loan is not true" do
      transaction_cost_criterion.financing_fee_is_percent_of_loan = false
      transaction_cost_criterion.financing_fee = some_int
      implementing_class.financing_fee.should == some_int
    end
    
    context "when financing_fee_is_percent_of_loan" do
      
      before(:each) {transaction_cost_criterion.financing_fee_is_percent_of_loan = true}
      
      context "and when no financing fee" do
        
        before(:each) {transaction_cost_criterion.financing_fee = nil}
        
        it "should be nil when no mortgage or loan amount" do
          implementing_class.financing_fee.should be nil
        end
        
        it "should be nil when mortgage_amount is present" do
          implementing_class.mortgage_amount = some_int
          implementing_class.financing_fee.should be nil
        end
        
        it "should be nil when loan_amount argument is present" do
          implementing_class.financing_fee(some_int).should be nil
        end
        
        it "should be nil when loan_amount argument and mortgage_amount are present" do
          implementing_class.mortgage_amount = some_int
          implementing_class.financing_fee(some_int).should be nil
        end
      end
      
      context "and when financing_fee" do
        
        before(:each) {transaction_cost_criterion.financing_fee = 2.0}
        
        it "should be nil when when neither mortgage_amount or loan_amount argument are present" do
          implementing_class.mortgage_amount.should be nil
          implementing_class.financing_fee.should be nil
        end
        
        it "should be percent of loan when loan_amount passed as argument" do
          mortgage_amount = 10_000_000
          expected = transaction_cost_criterion.financing_fee/100 * mortgage_amount
          implementing_class.financing_fee(mortgage_amount).should be_within(0.005).of expected
        end
        
        it "should be percent of loan when mortgage_amount is present and loan_amount not passed as argument" do
          implementing_class.mortgage_amount = 10_000_000
          expected = transaction_cost_criterion.financing_fee/100 * implementing_class.mortgage_amount
          implementing_class.financing_fee.should be_within(0.005).of expected
        end
        
        it "should be percent of loan as argument when both mortgage_amount present and loan_amount passed as argument" do
          implementing_class.mortgage_amount = 10_000_000
          loan_amount = implementing_class.mortgage_amount/2
          expected = loan_amount * transaction_cost_criterion.financing_fee/100
          implementing_class.financing_fee(loan_amount).should be_within(0.005).of expected
        end
      end
    end
    
  end
  
  describe "mortgageable_bond_costs" do
    it "should be nil" do
      implementing_class.mortgageable_bond_costs.should be nil
    end
  end
  
  describe "#discount" do
    context "when mortgage_amount present, but not loan_amount argument" do
      it "should be percent of loan" do
        transaction_cost_criterion.discounts_rate = 1.5
        implementing_class.mortgage_amount = 10_000_000
        expected = transaction_cost_criterion.discounts_rate/100 * implementing_class.mortgage_amount
        implementing_class.discount.should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument present, but not mortgage_amount" do
      it "should be percent of loan" do
        transaction_cost_criterion.discounts_rate = 1.5
        expected = transaction_cost_criterion.discounts_rate/100 * some_int
        implementing_class.discount(some_int).should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument and mortgage_amount both present" do
      it "should be percent of loan amount passed as argument" do
        transaction_cost_criterion.discounts_rate = 1.5
        expected = transaction_cost_criterion.discounts_rate/100 * some_int
        implementing_class.mortgage_amount = some_int/2
        implementing_class.discount(some_int).should be_within(0.005).of expected
      end
    end
    
    it "should be nil when not present" do
      implementing_class.mortgage_amount = some_int
      transaction_cost_criterion.discounts_rate = nil
      implementing_class.discount(some_int).should be nil
    end
  end
  
  describe "#permanent_placement_fee" do
    context "when mortgage_amount present, but not loan_amount argument" do
      it "should be percent of loan" do
        transaction_cost_criterion.permanent_placement_rate = 1.5
        implementing_class.mortgage_amount = 10_000_000
        expected = transaction_cost_criterion.permanent_placement_rate/100 * implementing_class.mortgage_amount
        implementing_class.permanent_placement_fee.should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument present, but not mortgage_amount" do
      it "should be percent of loan" do
        transaction_cost_criterion.permanent_placement_rate = 1.5
        expected = transaction_cost_criterion.permanent_placement_rate/100 * some_int
        implementing_class.permanent_placement_fee(some_int).should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument and mortgage_amount both present" do
      it "should be percent of loan amount passed as argument" do
        transaction_cost_criterion.permanent_placement_rate = 1.5
        expected = transaction_cost_criterion.permanent_placement_rate/100 * some_int
        implementing_class.mortgage_amount = some_int/2
        implementing_class.permanent_placement_fee(some_int).should be_within(0.005).of expected
      end
    end
    
    it "should be nil when not present" do
      implementing_class.mortgage_amount = some_int
      transaction_cost_criterion.permanent_placement_rate = nil
      implementing_class.permanent_placement_fee(some_int).should be nil
    end
  end
  
  describe "#fha_exam_fee" do
    context "when mortgage_amount present, but not loan_amount argument" do
      it "should be percent of loan" do
        transaction_cost_criterion.exam_fee_rate = 1.5
        implementing_class.mortgage_amount = 10_000_000
        expected = transaction_cost_criterion.exam_fee_rate/100 * implementing_class.mortgage_amount
        implementing_class.fha_exam_fee.should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument present, but not mortgage_amount" do
      it "should be percent of loan" do
        transaction_cost_criterion.exam_fee_rate = 1.5
        expected = transaction_cost_criterion.exam_fee_rate/100 * some_int
        implementing_class.fha_exam_fee(some_int).should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument and mortgage_amount both present" do
      it "should be percent of loan amount passed as argument" do
        transaction_cost_criterion.exam_fee_rate = 1.5
        expected = transaction_cost_criterion.exam_fee_rate/100 * some_int
        implementing_class.mortgage_amount = some_int/2
        implementing_class.fha_exam_fee(some_int).should be_within(0.005).of expected
      end
    end
    
    it "should be nil when not present" do
      implementing_class.mortgage_amount = some_int
      transaction_cost_criterion.exam_fee_rate = nil
      implementing_class.fha_exam_fee(some_int).should be nil
    end
  end
  
  describe "#first_year_mip" do
    context "when mortgage_amount present, but not loan_amount argument" do
      it "should be percent of loan" do
        transaction_cost_criterion.first_year_mortgage_insurance_premium_rate = 1.5
        implementing_class.mortgage_amount = 10_000_000
        expected = transaction_cost_criterion.first_year_mortgage_insurance_premium_rate/100 * implementing_class.mortgage_amount
        implementing_class.first_year_mip.should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument present, but not mortgage_amount" do
      it "should be percent of loan" do
        transaction_cost_criterion.first_year_mortgage_insurance_premium_rate = 1.5
        expected = transaction_cost_criterion.first_year_mortgage_insurance_premium_rate/100 * some_int
        implementing_class.first_year_mip(some_int).should be_within(0.005).of expected
      end
    end
    
    context "when loan_amount argument and mortgage_amount both present" do
      it "should be percent of loan amount passed as argument" do
        transaction_cost_criterion.first_year_mortgage_insurance_premium_rate = 1.5
        expected = transaction_cost_criterion.first_year_mortgage_insurance_premium_rate/100 * some_int
        implementing_class.mortgage_amount = some_int/2
        implementing_class.first_year_mip(some_int).should be_within(0.005).of expected
      end
    end
    
    it "should be nil when not present and loan_amount and mortgage amount present" do
      implementing_class.mortgage_amount = some_int
      transaction_cost_criterion.first_year_mortgage_insurance_premium_rate = nil
      implementing_class.first_year_mip(some_int).should be nil
    end
  end
  
  describe "legal_and_organizational" do
    it "should be as initialized" do
      transaction_cost_criterion.legal_and_organizational = some_int
      implementing_class.legal_and_organizational.should == some_int
    end
  end
  
  describe "third_party_reports" do
    it "should be as initialized" do
      transaction_cost_criterion.third_party_reports = some_int
      implementing_class.third_party_reports.should == some_int
    end
  end
  
  describe "other" do
    it "should be as initialized" do
      transaction_cost_criterion.other = some_int
      implementing_class.other.should == some_int
    end
  end
  
  describe "survey" do
    it "should be as initialized" do
      transaction_cost_criterion.survey = some_int
      implementing_class.survey.should == some_int
    end
  end
  
  describe "#title_and_recording" do
    
    it "should be title_and_recording when title_and_recording_is_percent_of_loan is not true" do
      transaction_cost_criterion.title_and_recording_is_percent_of_loan = false
      transaction_cost_criterion.title_and_recording = some_int
      implementing_class.title_and_recording.should == some_int
    end
    
    context "when title_and_recording_is_percent_of_loan" do
      
      before(:each) {transaction_cost_criterion.title_and_recording_is_percent_of_loan = true}
      
      context "and when no financing fee" do
        
        before(:each) {transaction_cost_criterion.title_and_recording = nil}
        
        it "should be nil when no mortgage or loan amount" do
          implementing_class.title_and_recording.should be nil
        end
        
        it "should be nil when mortgage_amount is present" do
          implementing_class.mortgage_amount = some_int
          implementing_class.title_and_recording.should be nil
        end
        
        it "should be nil when loan_amount argument is present" do
          implementing_class.title_and_recording(some_int).should be nil
        end
        
        it "should be nil when loan_amount argument and mortgage_amount are present" do
          implementing_class.mortgage_amount = some_int
          implementing_class.title_and_recording(some_int).should be nil
        end
      end
      
      context "and when title_and_recording" do
        
        before(:each) {transaction_cost_criterion.title_and_recording = 2.0}
        
        it "should be nil when when neither mortgage_amount or loan_amount argument are present" do
          implementing_class.mortgage_amount.should be nil
          implementing_class.title_and_recording.should be nil
        end
        
        it "should be percent of loan when loan_amount passed as argument" do
          mortgage_amount = 10_000_000
          expected = transaction_cost_criterion.title_and_recording/100 * mortgage_amount
          implementing_class.title_and_recording(mortgage_amount).should be_within(0.005).of expected
        end
        
        it "should be percent of loan when mortgage_amount is present and loan_amount not passed as argument" do
          implementing_class.mortgage_amount = 10_000_000
          expected = transaction_cost_criterion.title_and_recording/100 * implementing_class.mortgage_amount
          implementing_class.title_and_recording.should be_within(0.005).of expected
        end
        
        it "should be percent of loan as argument when both mortgage_amount present and loan_amount passed as argument" do
          implementing_class.mortgage_amount = 10_000_000
          loan_amount = implementing_class.mortgage_amount/2
          expected = loan_amount * transaction_cost_criterion.title_and_recording/100
          implementing_class.title_and_recording(loan_amount).should be_within(0.005).of expected
        end
      end
    end
    
  end
  
  describe "#total_development_costs" do
    it "should be total of all items" do
      transaction_cost_criterion.financing_fee_is_percent_of_loan = true
      transaction_cost_criterion.financing_fee = 2.0
      transaction_cost_criterion.discounts_rate = 1.5
      transaction_cost_criterion.permanent_placement_rate = 1.5
      transaction_cost_criterion.exam_fee_rate = 0.3
      transaction_cost_criterion.first_year_mortgage_insurance_premium_rate = 1.0
      transaction_cost_criterion.title_and_recording_is_percent_of_loan = true
      transaction_cost_criterion.title_and_recording = 0.07

      implementing_class.mortgage_amount = 10_000_000

      expected = transaction_cost_criterion.initial_deposit_to_replacement_reserve = some_int
      expected += implementing_class.estimate_of_repair_cost = some_int
      expected += transaction_cost_criterion.fha_inspection_fee = some_int
      expected += transaction_cost_criterion.legal_and_organizational = some_int
      expected += transaction_cost_criterion.survey = some_int
      expected += transaction_cost_criterion.other = some_int
      expected += transaction_cost_criterion.third_party_reports = some_int
      expected += implementing_class.financing_fee
      expected += implementing_class.discount
      expected += implementing_class.permanent_placement_fee
      expected += implementing_class.fha_exam_fee
      expected += implementing_class.first_year_mip
      expected += implementing_class.title_and_recording
      implementing_class.total_development_costs.should be_within(0.005).of expected
    end
  end
end