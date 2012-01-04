require "sec223f_acquisition/version"
require 'sec_223f_common_behavior'
require 'criterion_7'
require 'criterion_11'
require 'sec223f_cash_requirement'
require 'fha_utilities'

class Sec223fAcquisition::Criterion11
  include Criterion11::Sec223f::Acquisition
end

class Sec223fAcquisition::FixedAbatement
  include FhaUtilities::TaxAbatement::Fixed
end

class Sec223fAcquisition::VariableAbatement
  include FhaUtilities::TaxAbatement::Variable
end

class Sec223fAcquisition::Lease
  include FhaUtilities::Lease::Sec207223f
end

class Sec223fAcquisition::Sec223fAcquisition
  include Sec223fCommonBehavior
  include Sec223fCashRequirement
  
  attr_accessor :criterion_7, :criterion_11, :tax_abatement, :lease
  
  def initialize(args)
    
    value_of_the_leased_fee = nil
    
    if args[:lease]
      args[:lease].merge!(:loan_interest_rate_percent=>args[:criterion_5][:mortgage_interest_rate])
      self.lease = Sec223fAcquisition::Lease.new(args[:lease])
      
      if lease.valid?
        value_of_the_leased_fee = lease.value_of_the_leased_fee
        args[:criterion_3][:value_of_leased_fee] = value_of_the_leased_fee
        args[:criterion_4][:value_of_leased_fee] = value_of_the_leased_fee
        args[:criterion_5][:annual_ground_rent] = lease.first_year_payment
      end
    end
    
    if args[:tax_abatement]
      
      args[:tax_abatement][:mortgage_interest_rate_percent] = args[:criterion_5][:mortgage_interest_rate]
      args[:tax_abatement][:mortgage_insurance_premium_percent] = args[:criterion_5][:mortgage_insurance_premium_rate]
      args[:tax_abatement][:loan_term_in_months] = args[:criterion_5][:term_in_months]
      
      if args[:tax_abatement].each_key.any? {|k| k.to_s=~/^variable_phase/}
        self.tax_abatement = Sec223fAcquisition::VariableAbatement.new(args[:tax_abatement])
        
        if tax_abatement.valid?
          args[:criterion_5][:tax_abatement_present_value] = tax_abatement.present_value
        end
      else
        self.tax_abatement = Sec223fAcquisition::FixedAbatement.new(args[:tax_abatement])
        
        if tax_abatement.valid?
          if (pv = tax_abatement.present_value) == 0
            args[:criterion_5][:annual_tax_abatement] = tax_abatement.annual_amount
          else
            args[:criterion_5][:tax_abatement_present_value] = pv
          end
        end
      end
    end
    
    if args[:criterion_7].has_key?(:fha_inspection_fee) && !args[:criterion_7][:fha_inspection_fee].blank?
      crit_7_attrs = args[:criterion_7]
    else
      apartments = get_total_apartments args[:criterion_4] # maybe remove this in favor of #total_apartments
      crit_7_attrs = criterion_7_attribute_handler(args[:criterion_7], apartments)
    end
    self.criterion_7 = Criterion7::Criterion7.new crit_7_attrs
    self.transaction_cost_criterion = criterion_7
    
    if args[:criterion_11]
      self.criterion_11 = Sec223fAcquisition::Criterion11.new args[:criterion_11]
      self.criterion_11.value_of_leased_fee = value_of_the_leased_fee if value_of_the_leased_fee
      self.grant_or_loan = args[:criterion_11][:grants].to_f + 
                           args[:criterion_11][:gifts].to_f +
                           args[:criterion_11][:tax_credits].to_f +
                           args[:criterion_11][:public_loans].to_f + 
                           args[:criterion_11][:private_loans].to_f
    end
    
    super(args)
  end
  
  def transaction_amount_including_loan_closing_charges # Q: what happens when crit 11 involved?
    criterion_7.purchase_price_of_project.to_f + total_development_costs - estimate_of_repair_cost.to_f
  end
  
  def estimate_of_repair_cost
    criterion_7.repairs_and_improvements
  end
  
  def required_repairs; estimate_of_repair_cost; end
  
  def maximum_insurable_mortgage
    arr = [super] # get preliminary result
    arr << criterion_7.line_h
    arr << criterion_11.line_c if criterion_11
    arr.min
  end
  
  def mortgage_amount; maximum_insurable_mortgage; end
  
  def valid?
    val = super
    
    if criterion_7
      criterion_7_is_valid = criterion_7.valid? 
      criterion_7.errors.each {|k,v| errors.add k, v } unless criterion_7_is_valid
    end
    
    criterion_11_is_valid = true
    
    if criterion_11
      criterion_11_is_valid = criterion_11.valid?
      
      unless criterion_11_is_valid
        criterion_11.errors.each {|k,v| errors.add k, v unless errors[k].include?(k)}
      end
    end
    
    lease_is_valid = true
    lease_is_valid = lease.valid? if lease
    
    tax_abatement_is_valid = true
    tax_abatement_is_valid = tax_abatement.valid? if tax_abatement
    
    val && criterion_7_is_valid && criterion_11_is_valid && lease_is_valid && tax_abatement_is_valid
  end
  
  def as_json(options={})
    criteria = super
    criteria[:criterion_7] = criterion_7.as_json
    criteria[:criterion_11] = criterion_11.as_json if criterion_11
    mtg_candidates = [criteria[:criterion_7][:line_h][:result]]
    mtg_candidates << criteria[:criterion_5][:line_j][:line_h_plus_line_i]
    mtg_candidates << criteria[:criterion_4][:line_g][:line_d_or_line_e_minus_line_f]
    mtg_candidates << criteria[:criterion_3][:line_e][:line_a_minus_line_d]
    mtg_candidates << criteria[:criterion_1][:loan_request]
    mtg_candidates << criteria[:criterion_11][:line_c][:line_a_minus_line_b] if criterion_11
    criteria[:maximum_insurable_mortgage] = mtg_candidates.min
    {:loan=>criteria, :total_estimated_cash_requirement=> total_estimated_cash_requirement}
  end
  
  # Grew frustrated in my attempts to extend from sec_223f_common_behavior...
  def errors_to_json
    # errors_hash = Hash.new
    # blk = Proc.new do |k,v|
    #   v = v.first if v.is_a? Array
    #   if errors_hash.has_key?(k)
    #     errors_hash[k] << v unless errors_hash[k].include? v
    #   else
    #     errors_hash[k] = [v]
    #   end
    # end
    # criterion_3.errors.as_json.each &blk
    # criterion_4.errors.as_json.each &blk
    # criterion_5.errors.as_json.each &blk
    # criterion_7.errors.as_json.each &blk
    # errors.each &blk
    # errors_hash.to_json
    errors_as_json.to_json
  end
  
  def errors_as_json
    errors_hash = Hash.new
    blk = Proc.new do |k,v|
      v = v.first if v.is_a? Array
      if errors_hash.has_key?(k)
        errors_hash[k] << v unless errors_hash[k].include? v
      else
        errors_hash[k] = [v]
      end
    end
    criterion_3.errors.as_json.each &blk
    criterion_4.errors.as_json.each &blk
    criterion_5.errors.as_json.each &blk
    criterion_7.errors.as_json.each &blk
    errors.each &blk
    
    unless !lease || lease.errors.empty?
      errors_hash[:lease] = lease.errors.to_hash
      errors_hash[:lease].delete :loan_interest_rate_percent
      errors_hash.delete(:lease) if errors_hash[:lease].empty?
    end
    
    unless !tax_abatement || tax_abatement.errors.empty?
      errors_hash[:tax_abatement] = tax_abatement.errors.to_hash
      [:loan_term_in_months, :mortgage_interest_rate_percent,
       :mortgage_insurance_premium_percent].each do |ele| 
         errors_hash[:tax_abatement].delete(ele)
       end
      errors_hash.delete(:tax_abatement) if errors_hash[:tax_abatement].empty?
    end
    
    errors_hash
  end
  
  private
  
  def criterion_7_attribute_handler(attrs, total_apts)
    ret_args = attrs.clone
    inspection_params = {:repairs => ret_args[:repairs_and_improvements], 
                         :total_apartments => total_apts}
    ret_args[:fha_inspection_fee] = Criterion7.inspection_fee inspection_params
    ret_args
  end
  
end