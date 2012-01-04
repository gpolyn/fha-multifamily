require "sec223f_cash_requirement/version"
require 'hud_92264'
require 'hud_92013'

# monkey patch rounding, sucker
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

module Sec223fCashRequirement
  
  include Hud92013::Attachments::DevelopmentCosts
  include Hud92264::A3::TotalRequirementsForSettlement::PartB
  
  attr_accessor :initial_operating_deficit, :grant_or_loan
  
  def mortgage_amount; raise NotImplementedError; end
  
  def estimate_of_repair_cost; raise NotImplementedError; end
  
  def replacement_reserve
    transaction_cost_criterion.replacement_reserves_on_deposit
  end
  
  def major_movable_equipment
    transaction_cost_criterion.major_movable_equipment
  end
  
  def initial_deposit_to_reserve_fund
    transaction_cost_criterion.initial_deposit_to_replacement_reserve
  end
  
  def fha_inspection_fee
    transaction_cost_criterion.fha_inspection_fee
  end
  
  def financing_fee(loan_amount=nil)
    return transaction_cost_criterion.financing_fee unless transaction_cost_criterion.financing_fee_is_percent_of_loan
    return unless transaction_cost_criterion.financing_fee
    return unless loan_amount = mortgage_amount unless loan_amount
    (transaction_cost_criterion.financing_fee.to_f/100 * loan_amount).round_to 2
  end
  
  def title_and_recording(loan_amount=nil)
    return transaction_cost_criterion.title_and_recording unless transaction_cost_criterion.title_and_recording_is_percent_of_loan
    return unless transaction_cost_criterion.title_and_recording
    return unless loan_amount = mortgage_amount unless loan_amount
    (transaction_cost_criterion.title_and_recording.to_f/100 * loan_amount).round_to 2
  end
  
  def mortgageable_bond_costs
    nil
  end
  
  def discount(loan_amount=nil)
    disc = transaction_cost_criterion.discounts_rate
    loan_amount = mortgage_amount unless loan_amount
    loan_amount * disc.to_f/100 if disc
  end
  
  def fha_exam_fee(loan_amount=nil)
    rate = transaction_cost_criterion.exam_fee_rate
    loan_amount = mortgage_amount unless loan_amount
    loan_amount * rate.to_f/100 if rate
  end
  
  def third_party_reports
    transaction_cost_criterion.third_party_reports
  end
  
  def survey
    transaction_cost_criterion.survey
  end
  
  def other
    transaction_cost_criterion.other
  end
  
  def first_year_mip(loan_amount=nil)
    return unless rate = transaction_cost_criterion.first_year_mortgage_insurance_premium_rate
    loan_amount = mortgage_amount unless loan_amount
    loan_amount * rate.to_f/100
  end
  
  def permanent_placement_fee(loan_amount=nil)
    rate = transaction_cost_criterion.permanent_placement_rate
    loan_amount = mortgage_amount unless loan_amount
    loan_amount * rate.to_f/100 if rate
  end
  
  def legal_and_organizational
    transaction_cost_criterion.legal_and_organizational
  end
  
  def total_development_costs
    loan_amount = mortgage_amount
    
    legal_and_organizational.to_f + survey.to_f + other.to_f + third_party_reports.to_f +
    estimate_of_repair_cost.to_f + initial_deposit_to_reserve_fund.to_f + fha_inspection_fee.to_f +
    permanent_placement_fee(loan_amount).to_f + first_year_mip(loan_amount).to_f + 
    fha_exam_fee(loan_amount).to_f + discount(loan_amount).to_f + 
    title_and_recording(loan_amount).to_f + financing_fee(loan_amount).to_f 
  end
  
  protected
  
  attr_accessor :transaction_cost_criterion
  
end
