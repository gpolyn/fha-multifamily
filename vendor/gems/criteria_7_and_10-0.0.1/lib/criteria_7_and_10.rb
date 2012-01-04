require "criteria_7_and_10/version"
require 'active_support'
require 'active_model'

# monkey patch rounding, sucker
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

module Criteria7And10
  module ClassMethods
    def inspection_fee(args)
      return nil unless (apts = args[:total_apartments].to_i) > 0
      return unless args[:repairs]

      if (repairs = args[:repairs].to_f) > 0
        repairs/apts <= 3000 ? 30 * apts : 0.01 * repairs
      else
        0
      end
    end
  end
  
  module InstanceMethods
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    
    ATTRIBUTES = [:fha_inspection_fee, :third_party_reports, :other, :survey, 
                  :replacement_reserves_on_deposit, :major_movable_equipment,
                  :percent_multiplier, :initial_deposit_to_replacement_reserve, 
                  :title_and_recording_is_percent_of_loan, 
                  :financing_fee_is_percent_of_loan, :legal_and_organizational,
                  :title_and_recording, :financing_fee,
                  :first_year_mortgage_insurance_premium_rate, :exam_fee_rate, 
                  :mortgagable_bond_costs_rate, :discounts_rate, :permanent_placement_rate]

    attr_accessor *ATTRIBUTES
    
    included do
      validates :percent_multiplier, :first_year_mortgage_insurance_premium_rate, 
                :numericality => {:greater_than_or_equal_to => 0}
      validates :fha_inspection_fee, :third_party_reports, :other, :survey, 
                :replacement_reserves_on_deposit, :major_movable_equipment,
                :initial_deposit_to_replacement_reserve, :title_and_recording,
                :financing_fee, :legal_and_organizational,
                :exam_fee_rate, 
                :mortgagable_bond_costs_rate, :discounts_rate, :permanent_placement_rate, 
                :numericality => {:greater_than_or_equal_to => 0, :allow_blank => true}
      validates :first_year_mortgage_insurance_premium_rate,
                :exam_fee_rate, :mortgagable_bond_costs_rate, :discounts_rate, :permanent_placement_rate,
                :numericality => {:less_than_or_equal_to => 100, :allow_blank => true}
      validates :financing_fee_is_percent_of_loan, :title_and_recording_is_percent_of_loan,
                :inclusion=>{:in=>[true, false, nil], :message=> "must be one of true, false or nil"}
      validates :financing_fee, :numericality=>{:less_than_or_equal_to => 100, :allow_blank => true},
                :if=>:financing_fee_is_percent_of_loan
      validates :title_and_recording, :numericality=>{:less_than_or_equal_to => 100, :allow_blank => true},
                :if=>:title_and_recording_is_percent_of_loan
    end
    
    # def initialize(args={})
    #   self.attributes = args
    # end
    
    def line_b; raise NotImplementedError, "line_b implementation required"; end
        
    def other_fees
      return unless fha_inspection_fee || third_party_reports || survey || other
      fha_inspection_fee.to_f + third_party_reports.to_f + survey.to_f + other.to_f
    end
    
    alias :line_c :other_fees
    
    def sum_of_lines_a_through_d
      return unless line_a || line_b || line_c || line_d
      line_a.to_f + line_b.to_f + line_c.to_f + line_d.to_f
    end
    
    alias :line_e :sum_of_lines_a_through_d
    
    def sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment
      return unless replacement_reserves_on_deposit || major_movable_equipment
      replacement_reserves_on_deposit.to_f + major_movable_equipment.to_f
    end
    
    alias :line_f :sum_of_any_replacement_reserves_on_deposit_and_major_movable_equipment
    
    def line_g
      return unless line_e
      line_e - line_f.to_f
    end
    
    protected
    
    def attributes
      ATTRIBUTES.inject(
        ActiveSupport::HashWithIndifferentAccess.new
        ) do |result, key|
        result[key] = send(key)
        result
      end
    end

    # def attributes
    #   ATTRIBUTES.inject({}) do |result, key|
    #     result[key] = send(key)
    #     result
    #   end
    # end

    def attributes=(attrs)
      attrs.each_pair {|k, v| send("#{k}=", v)}
    end
    
  end
  
  def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
  end
end
