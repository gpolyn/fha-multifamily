require File.dirname(__FILE__) + "/../spec_helper.rb"

class TestClass
  include Hud92013::Attachments::DevelopmentCosts 
  attr_reader :initial_deposit_to_reserve_fund, :estimate_of_repair_cost,
              :fha_inspection_fee, :financing_fee, :mortgageable_bond_costs,
              :discount, :permanent_placement_fee, :legal_and_organizational,
              :title_and_recording, :fha_exam_fee, :first_year_mip,
              :loan_amount, :third_party_reports, :survey, :other
  def method_name
    0
  end
end

class TestClass2 < TestClass
  attr_writer :initial_deposit_to_reserve_fund, :estimate_of_repair_cost,
              :fha_inspection_fee, :financing_fee, :mortgageable_bond_costs,
              :discount, :permanent_placement_fee, :legal_and_organizational,
              :title_and_recording, :fha_exam_fee, :first_year_mip,
              :loan_amount, :third_party_reports, :survey, :other
end

describe Hud92013::Attachments::DevelopmentCosts do
  
  it_behaves_like "Hud92013::Attachments::DevelopmentCosts" do
    let(:host){TestClass.new}
  end 
  
  describe "#total_development_costs" do
    it "should be sum of development costs, when all provided" do
      host = TestClass2.new
      expected = 0
      [:initial_deposit_to_reserve_fund, :estimate_of_repair_cost, :survey,
       :fha_inspection_fee, :financing_fee, :mortgageable_bond_costs,
       :discount, :permanent_placement_fee, :legal_and_organizational,
       :title_and_recording, :fha_exam_fee, :first_year_mip, :third_party_reports,
       :other].each {|attr| host.send("#{attr.to_s}=", 12); expected += 12}
       host.total_development_costs.should == expected
    end
    
    it "should be 0, when no development costs provided" do
      host = TestClass.new
      host.total_development_costs.should == 0
    end
  end
  
end