module Hud92264
  module A3
    module TotalRequirementsForSettlement
      module PartB
        @@attributes = [:transaction_amount_including_loan_closing_charges, :required_repairs, 
                        :initial_operating_deficit, :mortgage_amount, :grant_or_loan, 
                        :replacement_reserve, :major_movable_equipment]
        
        @@attributes.each {|attr| define_method(attr) {raise NotImplementedError}}

        def line_1_a; transaction_amount_including_loan_closing_charges; end
        def line_2; required_repairs; end
        
        def line_1_c
          line_1_a
        end

        def line_3
          return unless line_1_c || line_2
          line_1_c.to_f + line_2.to_f
        end
        
        def subtotal_lines_1c_and_2; line_3; end
        def line_4_a; mortgage_amount; end

        def grant_or_loan_and_replacement_reserve_and_major_movable_equipment
          return unless grant_or_loan || replacement_reserve || major_movable_equipment
          grant_or_loan.to_f + replacement_reserve.to_f + major_movable_equipment.to_f
        end
        
        def line_4_b; grant_or_loan_and_replacement_reserve_and_major_movable_equipment; end

        def lines_4a_plus_4b_plus_5
          return unless line_4_a || line_4_b
          line_4_b.to_f + line_4_a.to_f
        end

        def line_6; lines_4a_plus_4b_plus_5; end

        def cash_investment_required
          return unless line_3 && line_6
          line_3 - line_6
        end

        def line_7; cash_investment_required; end
        def line_8; initial_operating_deficit; end
        
        def total_estimated_cash_requirement
          return unless line_7 || line_8
          (line_7.to_f + line_8.to_f).round(0)
        end
        
        def line_12; total_estimated_cash_requirement; end
      end
    end
  end
end
