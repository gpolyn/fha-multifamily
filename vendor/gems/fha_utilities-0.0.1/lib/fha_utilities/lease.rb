module FhaUtilities
  module Lease
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    
    ATTRIBUTES = [:has_option_to_buy, :first_year_payment, :payments_are_variable,
                  :payment_is_lump_sum_in_first_year, :term_in_years,
                  :as_is_value_of_land_in_fee_simple, :lease_capitalization_rate_percent,
                  :term_in_years_expresses_original_term_and_not_remaining_term,
                  :loan_interest_rate_percent, :is_renewable]

    attr_accessor *ATTRIBUTES
    
    included do
      validates :first_year_payment, :term_in_years, :as_is_value_of_land_in_fee_simple,
                :numericality => {:greater_than_or_equal_to => 0}
      validates :loan_interest_rate_percent,
                :numericality => {:greater_than_or_equal_to => 0, 
                                  :less_than_or_equal_to => 100}
      validates :lease_capitalization_rate_percent,
                :numericality => {:greater_than_or_equal_to => 0, 
                                  :less_than_or_equal_to => 100, 
                                  :allow_blank=>true}
      validates :is_renewable,
                :inclusion=>{:in=>[true, false], :message=> "must be true or false", 
                             :allow_blank=>true}
      validates :is_renewable, 
                :if => Proc.new {|a| a.term_in_years_expresses_original_term_and_not_remaining_term == true && 
                                     a.is_renewable != false},
                :presence=>{:message=> "can't be blank when term_in_years_expresses_original_term_and_not_remaining_term is true"}
      validates :has_option_to_buy, :payments_are_variable, :payment_is_lump_sum_in_first_year,
                :term_in_years_expresses_original_term_and_not_remaining_term,
                :inclusion=>{:in=>[true, false], :message=> "must be true or false"}
      validates :lease_capitalization_rate_percent,
                :numericality=>{:greater_than_or_equal_to=>:loan_interest_rate_percent},
                :if=>Proc.new {|a| a.has_option_to_buy_and_lease_cap_rate_percent && 
                                   a.loan_interest_rate_is_comparison_worthy}
      validates :payments_are_variable, :if => Proc.new {|a| a.has_option_to_buy == true},
                :inclusion=>{:in=>[false], :message=> "must be false when has_option_to_buy is true"}
      validate :variable_lease_payments, :if=>Proc.new{|a| a.payments_are_variable == true}
      validate :level_lease_payments, :if=>Proc.new{|a| a.payments_are_variable == false}
    end
    
    def initialize(args={})
      self.attributes = args
    end
    
    def value_of_the_leased_fee
      if has_option_to_buy && lease_capitalization_rate_percent
        (first_year_payment.to_f/(lease_capitalization_rate_percent.to_f/100)).round 2
      else
        as_is_value_of_land_in_fee_simple
      end
    end

    def attributes
      ATTRIBUTES.inject({}) do |result, key|
        result[key] = send(key)
        result
      end
    end

    def attributes=(attrs)
      attrs.each_pair {|k, v| send("#{k}=", v)}
    end
    
    protected
    
    def variable_lease_payments
      validate_payment 0.9
    end
    
    def level_lease_payments
      validate_payment 1
    end
    
    def has_option_to_buy_and_lease_cap_rate_percent
      has_option_to_buy == true && lease_capitalization_rate_percent
    end
    
    def loan_interest_rate_is_comparison_worthy
      loan_interest_rate_percent.is_a?(Numeric) && loan_interest_rate_percent >= 0
    end
    
    private
    
    def validate_payment(factor)
      begin
        return unless (value = as_is_value_of_land_in_fee_simple.to_f) > 0
        return unless (int = loan_interest_rate_percent.to_f) > 0
        return unless first_year_payment.to_f > 0
        return if payment_is_lump_sum_in_first_year == true
      rescue #Exception => e
        return
      end
      
      diff = first_year_payment - (value * int/100 * factor).round(2)
      errors.add(:first_year_payment, "is too high by #{diff.round(2)}") if diff > 0
    end
    
  end
  
  module Lease
    module NonSec207223fBehavior
      extend ActiveSupport::Concern
      include FhaUtilities::Lease

      attr_accessor :mortgage_term_in_years

      included do
        validates :mortgage_term_in_years, :numericality => {:greater_than_or_equal_to => 0}
        validate :original_term_is_99_years_and_renewable_or_remaining_term_runs_10_years_past_mortgage
      end

      protected

      def original_term_is_99_years_and_renewable_or_remaining_term_runs_10_years_past_mortgage
        begin
          return unless (mtg_term = mortgage_term_in_years.to_f) >= 0
          return unless (lse_term = term_in_years.to_f) >= 0
        rescue
          return
        end
        
        if term_in_years_expresses_original_term_and_not_remaining_term == true
          if lse_term >= 99 && is_renewable == false
            errors.add(:is_renewable, "can't be false if original lease term is 99 years or greater")
          end

          if lse_term < 99
            errors.add(:term_in_years, "can't be less than 99 when expressing the original lease term")
          end
        end

        if term_in_years_expresses_original_term_and_not_remaining_term == false
          if lse_term < mtg_term + 10
            errors.add(:term_in_years, "can't be less than the mortgage term in years plus 10")
          end
        end
      end
    end
  end
  
  module Lease
    module Sec207223f
      extend ActiveSupport::Concern
      include FhaUtilities::Lease
      
      included do
        validate :original_term_is_99_years_and_renewable_or_remaining_term_is_50_years
      end
      
      protected
      
      def original_term_is_99_years_and_renewable_or_remaining_term_is_50_years
        if term_in_years_expresses_original_term_and_not_remaining_term == true
          if term_in_years >= 99 && is_renewable == false
            errors.add(:is_renewable, "can't be false if original lease term is 99 years or greater")
          end
          
          if term_in_years < 99
            errors.add(:term_in_years, "can't be less than 99 when expressing the original lease term")
          end
        end
        
        if term_in_years_expresses_original_term_and_not_remaining_term == false
          if term_in_years < 50
            errors.add(:term_in_years, "can't be less than 50 when expressing the remaining lease term")
          end
        end
      end
    end
  end
  
  module Lease
    module Sec220
      extend ActiveSupport::Concern
      include FhaUtilities::Lease::NonSec207223fBehavior
    end
  end
  
  module Lease
    module Sec221d
      extend ActiveSupport::Concern
      include FhaUtilities::Lease::NonSec207223fBehavior
    end
  end
  
  module Lease
    module Sec232
      extend ActiveSupport::Concern
      include FhaUtilities::Lease::NonSec207223fBehavior
    end
  end
  
end