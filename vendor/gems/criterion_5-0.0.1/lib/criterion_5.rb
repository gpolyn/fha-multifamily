require 'rubygems'
require "criterion_5/version"
require 'bigdecimal'
require 'active_model'
# require 'active_support/core_ext/hash/indifferent_access'

# monkey patch rounding, sucker
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

module Criterion5
  # TODO: This is bullshit -- maybe switch to java big decimal?
  def self.debt_service_constant_percent(args)
    BigDecimal.mode(BigDecimal::ROUND_MODE, BigDecimal::ROUND_HALF_EVEN)
    BigDecimal.limit(20)
    twelve = BigDecimal("12")
    modified_rate = args[:mortgage_interest_rate].to_f/100
    big_rate = BigDecimal(modified_rate.to_s)
    per = big_rate/twelve
    one = BigDecimal("1")
    denom = one - one/(one + per)**args[:term_in_months]
    x = per/denom
    big_mip = BigDecimal(args[:mortgage_insurance_premium_rate].to_s)/BigDecimal("100")
    result = (x * twelve + big_mip) * BigDecimal("100")
    return result.to_f # may need to pull a to_f in here so that this is not reported out (in JSON) as a string
  end
  
  class Criterion5
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON
    
    ATTRIBUTES = [:mortgage_interest_rate, :percent_multiplier, 
                  :mortgage_insurance_premium_rate, :effective_income, 
                  :operating_expenses, :annual_replacement_reserve, :annual_tax_abatement,
                  :debt_service_constant, :annual_ground_rent,
                  :annual_special_assessment, :tax_abatement_present_value]

    attr_accessor *ATTRIBUTES

    alias :line_a :mortgage_interest_rate
    alias :line_b :mortgage_insurance_premium_rate
    alias :line_d :debt_service_constant
    alias :line_i :tax_abatement_present_value
    
    validates :mortgage_interest_rate, :percent_multiplier, :debt_service_constant,
              :mortgage_insurance_premium_rate, :effective_income, :operating_expenses,
              :numericality => {:greater_than_or_equal_to => 0}
    validates :annual_replacement_reserve, :annual_tax_abatement, :annual_ground_rent,
              :annual_special_assessment, :tax_abatement_present_value,
              :numericality => {:greater_than_or_equal_to => 0, :allow_blank => true}
    validates :mortgage_insurance_premium_rate, :mortgage_interest_rate, :debt_service_constant,
              :numericality => {:less_than_or_equal_to => 100, :allow_blank => true}
    validate :not_both_of_annual_tax_abatement_tax_abatement_present_value
    
    def initialize(args={})
      self.attributes = args
    end

    def net_income
      return unless effective_income && operating_expenses
      result = effective_income
      result -= operating_expenses
      result += annual_tax_abatement.to_f 
      result -= annual_replacement_reserve.to_f
    end
    
    def line_e
      return unless (ni = net_income) && percent_multiplier
      (ni * percent_multiplier.to_f/100).round_to(2)
    end

    def initial_curtail_rate
      return unless debt_service_constant && mortgage_insurance_premium_rate && mortgage_interest_rate
      debt_service_constant - mortgage_insurance_premium_rate - mortgage_interest_rate
    end

    alias :line_c :initial_curtail_rate

    def line_f
      return unless annual_ground_rent || annual_special_assessment
      annual_ground_rent.to_f + annual_special_assessment.to_f
    end

    def line_g
      return unless e = line_e
      e - line_f.to_f
    end

    def line_h
      return unless (g = line_g) && (d = line_d)
      return unless d > 0
      (g/(d.to_f/100)).round_to(2)
    end

    def line_h_plus_line_i
      return unless (h = line_h)
      ((h + line_i.to_f)/100).truncate * 100
    end

    alias :line_j :line_h_plus_line_i
    
    def as_json(options={})
      result = Hash.new
      result[:line_a] = {:mortgage_interest_rate=>mortgage_interest_rate}
      result[:line_b] = {:mortgage_insurance_premium_rate=>mortgage_insurance_premium_rate}
      result[:line_c] = {:initial_curtail_rate=>initial_curtail_rate}
      result[:line_d] = {:sum_of_above_rates=>debt_service_constant}
      result[:line_e] = {:net_income=>net_income, :effective_income=>line_e, :percent_multiplier=>percent_multiplier}
      result[:line_f] = {:annual_ground_rent=>annual_ground_rent, :annual_special_assessment=>annual_special_assessment,
                          :sum=>line_f}
      result[:line_g] = {:line_e_minus_line_f => line_g}
      result[:line_h] = {:line_g_divided_by_line_d => line_h}
      result[:line_i] = {:tax_abatement_present_value => tax_abatement_present_value}
      result[:line_j] = {:line_h_plus_line_i => line_h_plus_line_i}
      result
    end

    protected
    
    def not_both_of_annual_tax_abatement_tax_abatement_present_value
      unless tax_abatement_present_value.blank? || annual_tax_abatement.blank?
        errors.add :tax_abatement_present_value, "is mutually exclusive annual_tax_abatement"
        errors.add :annual_tax_abatement, "is mutually exclusive with tax_abatement_present_value" 
      end
    end

    def attributes
      ATTRIBUTES.inject({}
        # ActiveSupport::HashWithIndifferentAccess.new
        ) do |result, key|
        result[key] = send(key)
        result
      end
    end

    def attributes=(attrs)
      attrs.each_pair {|k, v| send("#{k}=", v)}
    end

  end
  
end

# class Criterion5::Criterion5
#   
#   ATTRIBUTES = [:mortgage_interest_rate, :percent_multiplier, 
#                 :mortgage_insurance_premium_rate, 
#                 :debt_service_constant, :net_income, :annual_ground_rent,
#                 :annual_special_assessment, :tax_abatement_present_value]
#                 
#   attr_accessor *ATTRIBUTES
#   
#   alias :line_a :mortgage_interest_rate
#   alias :line_b :mortgage_insurance_premium_rate
#   alias :line_d :debt_service_constant
#   alias :line_i :tax_abatement_present_value
#   
#   def initialize(args={})
#     self.attributes = args
#   end
#   
#   def initial_curtail_rate
#     debt_service_constant - mortgage_insurance_premium_rate - mortgage_interest_rate
#   end
#   
#   alias :line_c :initial_curtail_rate
#   
#   def line_e
#     (net_income * percent_multiplier.to_f/100).round_to(2)
#   end
#   
#   def line_f
#     annual_ground_rent + annual_special_assessment
#   end
#   
#   def line_g
#     line_e - line_f
#   end
#   
#   def line_h
#     (line_g/(line_d.to_f/100)).round_to(2)
#   end
#   
#   def line_h_plus_line_i
#     ((line_h + line_i)/100).truncate * 100
#   end
#   
#   alias :line_j :line_h_plus_line_i
#   
#   protected
#   
#   def attributes
#     ATTRIBUTES.inject({}) do |result, key|
#       result[key] = send(key)
#       result
#     end
#   end
#   
#   def attributes=(attrs)
#     attrs.each_pair {|k, v| send("#{k}=", v)}
#   end
#   
# end
