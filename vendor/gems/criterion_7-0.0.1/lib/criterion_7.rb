require 'rubygems'
require "criterion_7/version"
require 'criteria_7_and_10'
require 'active_support'
require 'active_model'

module Criterion7
  
  extend Criteria7And10::ClassMethods
  extend ActiveSupport::Concern
  include Criteria7And10
  include ActiveModel::Validations

  included do
    validates :purchase_price_of_project, 
              :numericality =>{:greater_than_or_equal_to => 0}
    validates :repairs_and_improvements,
              :numericality =>{:greater_than_or_equal_to => 0, :allow_blank => true}
  end
  
  ATTRIBUTES = [:purchase_price_of_project, :repairs_and_improvements]

  attr_accessor *ATTRIBUTES

  alias :line_a :purchase_price_of_project
  alias :line_b :repairs_and_improvements
  
  def initialize(args={})
    self.attributes = args
  end
  
  def loan_closing_charges
    return if required_closing_charges_are_not_present
    step_9
  end
  
  alias :line_d :loan_closing_charges
  
  def line_h
    return unless percent_multiplier && (g = line_g)
    ((percent_multiplier.to_f/100 * g)/100).truncate * 100
  end
  
  def as_json(options=nil)
    ret = Hash.new
    ret[:line_a] = {:purchase_price_of_project=>line_a}
    ret[:line_b] = {:repairs_and_improvements=>line_b}
    ret[:line_c] = {:other_fees=>line_c}
    ret[:line_d] = {:loan_closing_charges=>line_d}
    ret[:line_e] = {:sum_of_line_a_through_line_d=>line_e}
    ret[:line_f] = {:sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment => line_f}
    ret[:line_g] = {:line_e_minus_line_f=>line_g}
    ret[:line_h] = {:percent_multiplier=>percent_multiplier, :result=>line_h}
    ret
  end
  
  protected
  
  def required_closing_charges_are_not_present
    !purchase_price_of_project && !first_year_mortgage_insurance_premium_rate &&
    !percent_multiplier
  end
  
  def step_1
    ret = purchase_price_of_project
    ret += repairs_and_improvements.to_f
    ret += legal_and_organizational.to_f
    ret += title_and_recording.to_f unless title_and_recording_is_percent_of_loan
    ret += initial_deposit_to_replacement_reserve.to_f
    ret += financing_fee.to_f unless financing_fee_is_percent_of_loan
    ret += other_fees.to_f
  end
  
  def step_2
    step_1 - replacement_reserves_on_deposit.to_f - major_movable_equipment.to_f
  end
  
  def step_3
    percent_multiplier.to_f/100 * step_2
  end
  
  def step_4
    ret = first_year_mortgage_insurance_premium_rate 
    ret += permanent_placement_rate.to_f
    ret += mortgagable_bond_costs_rate.to_f
    ret += financing_fee.to_f if financing_fee_is_percent_of_loan
    ret += title_and_recording.to_f if title_and_recording_is_percent_of_loan
    ret += exam_fee_rate.to_f
    ret += discounts_rate.to_f
  end
  
  def step_5
    (percent_multiplier.to_f/100 * step_4).round_to 3
  end
  
  def step_6
    100 - step_5
  end
  
  attr_accessor :loan_amount
  
  def step_7
    ret = step_3/(step_6/100)
    self.loan_amount = (ret/100).truncate * 100
  end
  
  def percent_of_loan_rounded_to_2(val)
    (loan_amount * val.to_f/100).round_to(2)
  end
  
  def step_8
    loan = step_7
    ret = percent_of_loan_rounded_to_2(first_year_mortgage_insurance_premium_rate)
    ret += percent_of_loan_rounded_to_2(permanent_placement_rate)
    ret += percent_of_loan_rounded_to_2(mortgagable_bond_costs_rate)
    ret += financing_fee_is_percent_of_loan ? percent_of_loan_rounded_to_2(financing_fee) : financing_fee.to_f
    ret += percent_of_loan_rounded_to_2(exam_fee_rate)
    ret += percent_of_loan_rounded_to_2(discounts_rate)
  end
  
  def step_9
    ret = step_8
    ret += legal_and_organizational.to_f
    ret += initial_deposit_to_replacement_reserve.to_f
    ret += if title_and_recording_is_percent_of_loan
        percent_of_loan_rounded_to_2(title_and_recording)
      else
        title_and_recording.to_f
      end
  end
  
  # likely a temporary approach to refactoring the organization of the code
  # class Criterion7
  #   include Criterion7
  # end
  
end

# likely a temporary approach to refactoring the organization of the code
class Criterion7::Criterion7
  include Criterion7
end
