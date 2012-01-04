module Criterion11
  
  module CommonAttributes
    
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    
    ATTRIBUTES = [:grants, :gifts, :private_loans, :public_loans, :value_of_leased_fee,
                  :tax_credits, :cost_containment_mortgage_deduction,
                  :excess_unusual_land_improvement, :unpaid_balance_of_special_assessment]

    attr_accessor *ATTRIBUTES

    included do
      validates :grants, :gifts, :private_loans, :public_loans, :value_of_leased_fee,
                :tax_credits, :cost_containment_mortgage_deduction,
                :excess_unusual_land_improvement, :unpaid_balance_of_special_assessment,
                :numericality => {:greater_than_or_equal_to => 0, :allow_blank=>true}
    end
    
    alias :line_b2 :tax_credits
    alias :line_b3 :value_of_leased_fee
    alias :line_b4 :excess_unusual_land_improvement
    alias :line_b5 :cost_containment_mortgage_deduction
    alias :line_b6 :unpaid_balance_of_special_assessment
    
    def initialize(args={})
      self.attributes = args
    end
    
    def line_a
      raise NotImplementedError
    end
    
    def loans
      return unless private_loans || public_loans
      private_loans.to_f + public_loans.to_f
    end

    def grants_loans_gifts
      return unless grants || loans || gifts
      grants.to_f + loans.to_f + gifts.to_f
    end
    
    alias :line_b1 :grants_loans_gifts
    
    def sum_of_lines_b1_through_b6
      return unless line_b1 || line_b2 || line_b3 ||
                    line_b4 || line_b5 || line_b6
                    
      line_b1.to_f + line_b2.to_f + line_b3.to_f +
      line_b4.to_f + line_b5.to_f + line_b6.to_f
    end
    
    alias :line_b7 :sum_of_lines_b1_through_b6
    
    def line_a_minus_line_b7
      return unless b7 = line_b7
      
      line_a - b7
    end
    
    def line_c
      line_a_minus_line_b7
    end

    def attributes
      ATTRIBUTES.inject({}) do |result, key|
        result[key.to_sym] = send(key)
        result
      end
    end

    def attributes=(attrs)
      attrs.each_pair {|k, v| send("#{k}=", v)}
    end
  end
end