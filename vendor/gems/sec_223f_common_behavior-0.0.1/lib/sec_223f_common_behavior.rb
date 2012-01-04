require "sec_223f_common_behavior/version"
require 'active_support'
require "active_model"
require "criterion_3"
require "criterion_4"
require "criterion_5"

module Sec223fCommonBehavior
  extend ActiveSupport::Concern
  include ActiveModel::Validations
  
  included do
    validate :loan_request_is_zero_or_greater_if_given
    validates :term_in_months, :numericality => {:greater_than => 0, :less_than_or_equal_to => 420}
    validates :gross_residential_income, :numericality => {:greater_than_or_equal_to => 0}
    validates :residential_occupancy_percent, :minimum_residential_occupancy_percent,
              :maximum_residential_occupancy_percent,
              :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
    validates :minimum_annual_replacement_reserve_per_unit, 
              :numericality=>{:greater_than_or_equal_to=>0, :allow_blank=>true}
    validates :annual_replacement_reserve_per_unit, 
              :numericality=>{:greater_than_or_equal_to=>:minimum_annual_replacement_reserve_per_unit},
              :if => :minimum_annual_replacement_reserve_per_unit
    validates :annual_replacement_reserve_per_unit, :numericality=>{:greater_than_or_equal_to=>0, :allow_blank=>true}
    validate :residential_occupancy_percent_is_greater_than_or_equal_to_minimum, 
             :unless => Proc.new {|a| a.minimum_residential_occupancy_percent.to_f > 100 || a.residential_occupancy_percent.to_f < 0}
    validates :gross_commercial_income, 
              :numericality => {:greater_than_or_equal_to => 0, :allow_blank=>true}
    validates :operating_expenses_is_percent_of_effective_gross_income, 
              :inclusion=>{:in=>[true, false, nil], :message=>"must be one of true, false or nil"}
    validates :maximum_commercial_occupancy_percent, :commercial_occupancy_percent, 
              :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100},
              :if => :gross_commercial_income
    validates :operating_expenses, :numericality =>{:greater_than_or_equal_to=>0}
    validates :operating_expenses, :numericality=>{:less_than_or_equal_to=>100},
              :if=>Proc.new {|a| a.operating_expenses_is_percent_of_effective_gross_income == true }
  end
  
  attr_accessor :criterion_1, :criterion_3, :criterion_4, :criterion_5, :term_in_months, 
                :gross_residential_income, :gross_commercial_income, :commercial_occupancy_percent,
                :residential_occupancy_percent, :maximum_commercial_occupancy_percent,
                :minimum_residential_occupancy_percent, :maximum_residential_occupancy_percent,
                :operating_expenses, :annual_replacement_reserve_per_unit,
                :operating_expenses_is_percent_of_effective_gross_income, :minimum_annual_replacement_reserve_per_unit
  
  def initialize(args)
    overide_errors_as_json_method
    self.annual_replacement_reserve_per_unit = args[:annual_replacement_reserve_per_unit]
    self.minimum_annual_replacement_reserve_per_unit = args[:minimum_annual_replacement_reserve_per_unit]
    self.criterion_1 = args[:loan_request]
    self.criterion_3 = Criterion3::Criterion3.new(args[:criterion_3])
    self.criterion_4 = Criterion4::Criterion4AcceptingCNAParameters.new(args[:criterion_4])
    criterion_5_attribute_handler(args[:criterion_5])
  end
  
  def loan_request=(val)
    self.criterion_1 = val
  end
  
  def loan_request
    criterion_1
  end
  
  def valid?
    is_valid = super
    criterion_3_is_valid = criterion_3.valid?
    criterion_4_is_valid = criterion_4.valid?
    criterion_5_is_valid = criterion_5 ? criterion_5.valid? : true
    criteria_are_valid = criterion_3_is_valid && criterion_4_is_valid && criterion_5_is_valid
    return true if is_valid && criteria_are_valid
    
    unless criteria_are_valid
      errs = {}
      errs[:criterion_3] = criterion_3.errors unless criterion_3_is_valid
      errs[:criterion_4] = criterion_4.errors unless criterion_4_is_valid
      errs[:criterion_5] = criterion_5.errors unless criterion_5_is_valid
      errors.set_error_instance_variables errs
    end
    false
  end
  
  # def errors
  #   # add any errors from criteria that are not already present
  #   criterion_3.errors.each {|k,v| super.add k, v } if criterion_3
  # end
  
  def maximum_insurable_mortgage
    arr = [criterion_3.line_e, criterion_4.line_g, criterion_5.line_j]
    arr << criterion_1 unless criterion_1.blank?
    arr.min
  end
  
  def as_json(options={})
    result = Hash.new
    result[:criterion_1] = {:loan_request=>loan_request}
    result[:criterion_3] = criterion_3.as_json
    result[:criterion_4] = criterion_4.as_json
    result[:criterion_5] = criterion_5.as_json
    result
  end
  
  protected
  
  def residential_occupancy_percent_is_greater_than_or_equal_to_minimum
    return unless residential_occupancy_percent && minimum_residential_occupancy_percent
    if residential_occupancy_percent < minimum_residential_occupancy_percent
      str = "must be greater than or equal to minimum residential occupancy percent"
      errors.add(:residential_occupancy_percent, str)
    end
  end
  
  def get_total_apartments(attrs)
    ret = attrs[:number_of_no_bedroom_units].to_i 
    ret += attrs[:number_of_one_bedroom_units].to_i
    ret += attrs[:number_of_two_bedroom_units].to_i
    ret += attrs[:number_of_three_bedroom_units].to_i 
    ret += attrs[:number_of_four_or_more_bedroom_units].to_i
  end
  
  def loan_request_is_zero_or_greater_if_given
    return if criterion_1.blank?
    unless criterion_1 >= 0
      errors.add(:loan_request, "Loan request (criterion_1) must be greater than or equal to 0")
    end
  end
  
  private
  
  def overide_errors_as_json_method
    errors.instance_eval {
      def set_error_instance_variables(args)
        @crit ||= Hash.new
        args.each {|k,v| @crit[k] = v }
        @crit
      end
      
      def as_json(options=nil)
        ret = to_hash
        @crit.each {|k,v| ret[k] = v } if @crit
        ret
      end
    }
  end
  
  def criterion_5_attribute_handler(attrs)
    self.term_in_months = attrs[:term_in_months]
    self.gross_residential_income = attrs[:gross_residential_income]
    self.gross_commercial_income = attrs[:gross_commercial_income]
    self.commercial_occupancy_percent = attrs[:commercial_occupancy_percent]
    self.residential_occupancy_percent = attrs[:residential_occupancy_percent]
    self.minimum_residential_occupancy_percent = attrs[:minimum_residential_occupancy_percent]
    self.maximum_commercial_occupancy_percent = attrs[:maximum_commercial_occupancy_percent]
    self.maximum_residential_occupancy_percent = attrs[:maximum_residential_occupancy_percent]
    self.operating_expenses = attrs[:operating_expenses]
    self.operating_expenses_is_percent_of_effective_gross_income = attrs[:operating_expenses_is_percent_of_effective_gross_income]
    valid?
    
    args = {}

    dsc_validator = Criterion5::Criterion5.new(:mortgage_interest_rate=>attrs[:mortgage_interest_rate],
                                               :mortgage_insurance_premium_rate=>attrs[:mortgage_insurance_premium_rate])
    args[:mortgage_interest_rate] = attrs[:mortgage_interest_rate]
    args[:mortgage_insurance_premium_rate] = attrs[:mortgage_insurance_premium_rate]
    args[:term_in_months] = attrs[:term_in_months]
    args2 = attrs.dup
    dsc_validator.valid?
                
    if dsc_validator.errors[:mortgage_insurance_premium_rate].empty? &&
       dsc_validator.errors[:mortgage_interest_rate].empty? && errors[:term_in_months].empty?
      args2[:debt_service_constant] = Criterion5::debt_service_constant_percent(args)
    else
      args2[:debt_service_constant] = nil
    end
    
    if (income_attributes_valid = income_attributes_valid?)
      commercial = 0
          
      if gross_commercial_income
        pct = ([commercial_occupancy_percent, maximum_commercial_occupancy_percent].min).to_f/100
        commercial = pct * gross_commercial_income
      end
      res_pct = ([maximum_residential_occupancy_percent, residential_occupancy_percent].min).to_f/100
      residential = res_pct * gross_residential_income
      args2[:effective_income] = commercial + residential
    else
      args2[:effective_income] = nil
    end

    args2[:operating_expenses] = if opex_attributes_valid?
      if operating_expenses_is_percent_of_effective_gross_income
        income_attributes_valid ? args2[:effective_income] * operating_expenses.to_f/100 : nil
      else
        operating_expenses
      end
    else
      nil
    end
    
    args2[:annual_replacement_reserve] = if errors[:annual_replacement_reserve_per_unit].empty? && criterion_4.total_apartments && criterion_4.total_apartments > 0
      criterion_4.total_apartments * annual_replacement_reserve_per_unit.to_f
    else
      nil
    end

    eles = [:term_in_months, :gross_residential_income, :gross_commercial_income, :commercial_occupancy_percent,
            :residential_occupancy_percent, :maximum_commercial_occupancy_percent, :gross_residential_income,
            :operating_expenses_is_percent_of_effective_gross_income,
            :minimum_residential_occupancy_percent, :maximum_residential_occupancy_percent]
    eles.each {|ele| args2.delete(ele)}
    self.criterion_5 = Criterion5::Criterion5.new(args2)
  end
  
  def income_attributes_valid?
    errors[:gross_residential_income].empty? && errors[:gross_commercial_income].empty? && 
    errors[:commercial_occupancy_percent].empty? && errors[:residential_occupancy_percent].empty? && 
    errors[:maximum_residential_occupancy_percent].empty? && errors[:maximum_commercial_occupancy_percent].empty? &&
    errors[:minimum_residential_occupancy_percent].empty?
  end
  
  def opex_attributes_valid?
    errors[:operating_expenses_is_percent_of_effective_gross_income].empty? && errors[:operating_expenses].empty?
  end
  
end
