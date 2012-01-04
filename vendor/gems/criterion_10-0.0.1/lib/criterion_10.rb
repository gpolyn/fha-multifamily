require 'rubygems'
require "criterion_10/version"
require 'criteria_7_and_10'
require 'active_support'
require 'active_model'

module Criterion10
  
  extend Criteria7And10::ClassMethods
  extend ActiveSupport::Concern
  include Criteria7And10
  include ActiveModel::Validations
  
  ATTRIBUTES = [:existing_indebtedness, :repairs, :value_in_fee_simple]

  attr_accessor *ATTRIBUTES
  
  included do
    validates :existing_indebtedness, 
              :numericality =>{:greater_than_or_equal_to => 0}
    validates :value_in_fee_simple, 
              :numericality =>{:greater_than_or_equal_to => 0}
    validates :repairs,
              :numericality =>{:greater_than_or_equal_to => 0, :allow_blank => true}
  end

  alias :line_a :existing_indebtedness
  alias :line_b :repairs
  
  def initialize(args={})
    self.attributes = args
  end
  
  def loan_closing_charges
    return if all_closing_charges_nil
    step_7.round(2)
  end
  
  alias :line_d :loan_closing_charges
  
  def line_g
    return unless e = line_e
    ((e - line_f.to_f)/100).truncate * 100
  end
  
  alias :line_e_minus_line_f :line_g
  
  def line_h
    return unless percent_multiplier && value_in_fee_simple
    ((percent_multiplier.to_f/100 * value_in_fee_simple)/100).truncate * 100
  end
  
  alias :eighty_percent_of_value :line_h
  
  def line_i
    return unless (g = line_g) && (h = line_h)
    [g, h].max
  end
  
  def as_json(options=nil)
    ret = Hash.new
    ret[:line_a] = {:total_existing_indebtedness=>line_a}
    ret[:line_b] = {:required_repairs=>line_b}
    ret[:line_c] = {:other_fees=>line_c}
    ret[:line_d] = {:loan_closing_charges=>line_d}
    ret[:line_e] = {:sum_of_line_a_through_line_d=>line_e}
    ret[:line_f] = {:sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment => line_f}
    ret[:line_g] = {:line_e_minus_line_f=>line_g}
    ret[:line_h] = {:eighty_percent_multiplier=>percent_multiplier,:value=>value_in_fee_simple,:result=>line_h}
    ret[:line_i] = {:greater_of_line_g_or_line_h=>line_i}
    ret
  end
  
  protected
  
  def all_closing_charges_nil
    !existing_indebtedness && !first_year_mortgage_insurance_premium_rate &&
    !percent_multiplier
  end
  
  def step_1
    ret = existing_indebtedness.to_f
    ret += repairs.to_f
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
    ret = first_year_mortgage_insurance_premium_rate.to_f
    ret += permanent_placement_rate.to_f
    ret += mortgagable_bond_costs_rate.to_f
    ret += financing_fee.to_f if financing_fee_is_percent_of_loan
    ret += title_and_recording.to_f if title_and_recording_is_percent_of_loan
    ret += exam_fee_rate.to_f
    ret += discounts_rate.to_f
  end
  
  def step_4
    (100 - step_3).to_f/100
  end
  
  attr_accessor :loan_amount
  
  def step_5
    amt = step_2.to_f/step_4
    self.loan_amount = amt # (amt/100).truncate * 100
  end
  
  def percent_of_loan_rounded_to_2(val)
    (loan_amount * val.to_f/100).round_to(2)
  end
  
  def step_6
    step_5
    ret = percent_of_loan_rounded_to_2(first_year_mortgage_insurance_premium_rate)
    ret += percent_of_loan_rounded_to_2(permanent_placement_rate)
    ret += percent_of_loan_rounded_to_2(mortgagable_bond_costs_rate)
    ret += financing_fee_is_percent_of_loan ? percent_of_loan_rounded_to_2(financing_fee) : financing_fee.to_f
    ret += percent_of_loan_rounded_to_2(exam_fee_rate)
    ret += percent_of_loan_rounded_to_2(discounts_rate)
  end
  
  def step_7
    ret = step_6
    ret += legal_and_organizational.to_f
    ret += initial_deposit_to_replacement_reserve.to_f
    ret += if title_and_recording_is_percent_of_loan
        percent_of_loan_rounded_to_2(title_and_recording)
      else
        title_and_recording.to_f
      end
  end
end

class Criterion10::Criterion10
  include Criterion10
end
