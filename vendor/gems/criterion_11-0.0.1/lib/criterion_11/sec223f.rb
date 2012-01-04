module Criterion11
  
  module Sec223f
    extend ActiveSupport::Concern
    include ActiveModel::Serializers::JSON
    
    def as_json(options={})
      ret = Hash.new
      ret[:line_a] = {:project_cost=>line_a}
      ret[:line_b1] = {:grants_loans_gifts=>line_b1}
      ret[:line_b2] = {:tax_credits=>line_b2}
      ret[:line_b3] = {:value_of_leased_fee=>line_b3}
      ret[:line_b4] = {:excess_unusual_land_improvement_cost=>line_b4}
      ret[:line_b5] = {:cost_containment_mortgage_deductions => line_b5}
      ret[:line_b6] = {:unpaid_balance_of_special_assessment=>line_b6}
      ret[:line_b7] = {:sum_of_lines_1_through_6=>line_b7}
      ret[:line_c] = {:line_a_minus_line_b=>line_c}
      ret
    end
    
    module Refinance
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include Criterion10
      include CommonAttributes
      include Sec223f
      
      included do
        validate :private_loan_amount_within_maximum
      end

      def private_loan_amount_within_maximum
        return unless errors.empty?

        if (max = 0.925 * value_in_fee_simple) < line_c + private_loans
          msg = "when added to the mortgage amount must not exceed 92.5%" + 
                " of project value (#{max})"
          errors.add(:private_loans, msg)
        end
      end

      protected :private_loan_amount_within_maximum
      
      def project_cost
        (step_5/100).truncate * 100
      end
      
      def line_a; project_cost; end
      
      protected
      
      def step_2
        super - line_b7.to_f
      end
      
    end
    
    module Acquisition
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include Criterion7
      include CommonAttributes
      include Sec223f
      
      attr_accessor :value_in_fee_simple
      
      included do
        validates :value_in_fee_simple, 
                  :numericality =>{:greater_than_or_equal_to => 0}
        validate :private_loan_amount_within_maximum,
                 :if=>:private_loans
      end

      def private_loan_amount_within_maximum
        return unless errors.empty?

        if (max = 0.925 * value_in_fee_simple) < line_c + private_loans
          msg = "when added to the mortgage amount must not exceed 92.5%" + 
                " of project value (#{max})"
          errors.add(:private_loans, msg)
        end
      end

      protected :private_loan_amount_within_maximum
      
      
      def project_cost
        step_7
      end
      
      def line_a; project_cost; end
      
      protected
      
      def step_2
        super - line_b7.to_f
      end
      
      def step_3
        step_2
      end
      
      def step_5
        step_4
      end
      
    end
  end
end