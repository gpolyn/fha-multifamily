require 'rubygems'
require "criterion_3/version"
require "active_model"

# monkey patch rounding, sucker
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

class Criterion3::Criterion3
  include ActiveModel::Validations
  # include ActiveModel::Serializers::JSON
  # include ActiveModel::Serializers::Xml
  
  ATTRIBUTES = [:value_in_fee_simple, :percent_multiplier, :value_of_leased_fee, 
                :excess_unusual_land_improvement,
                :cost_containment_mortgage_deduction, 
                :unpaid_balance_of_special_assessments]
                
  attr_accessor *ATTRIBUTES
  
  alias :line_b_1 :value_of_leased_fee 
  alias :line_b_3 :excess_unusual_land_improvement 
  alias :line_b_4 :cost_containment_mortgage_deduction 
  alias :line_c :unpaid_balance_of_special_assessments
  
  validates :value_in_fee_simple, :percent_multiplier, :numericality => {:greater_than_or_equal_to => 0}
  validates :value_of_leased_fee, :excess_unusual_land_improvement, :cost_containment_mortgage_deduction, 
            :unpaid_balance_of_special_assessments,
            :numericality => {:greater_than_or_equal_to => 0, :allow_blank => true}
  
  def initialize(args={})
    self.attributes = args
  end
  
  def total_line_a
    return unless (val = value_in_fee_simple) && (pct = percent_multiplier)
    (val * pct.to_f/100).round_to(2)
  end
  
  def total_line_b
    return unless percent_multiplier && (line_b_1 || line_b_3 || line_b_4)
    ((line_b_1.to_f + line_b_3.to_f + line_b_4.to_f) * percent_multiplier.to_f/100).round_to(2)
  end
  
  def line_d
    return unless (b = total_line_b) || line_c
    b.to_f + line_c.to_f
  end
  
  def line_e
    return unless (a = total_line_a)
    ((a - line_d.to_f)/100).truncate * 100
  end
  
  def as_json(options={})
    result = Hash.new
    result[:line_a] = {:value_in_fee_simple=>value_in_fee_simple, :percent_multiplier=>percent_multiplier,
                       :net_value=>total_line_a}
    result[:line_b_1] = {:value_of_leased_fee=>value_of_leased_fee}
    result[:line_b_3] = {:excess_unusual_land_improvement=>excess_unusual_land_improvement}
    result[:line_b_4] = {:cost_containment_mortgage_deduction=>cost_containment_mortgage_deduction}
    result[:line_b_5] = {:total_lines_1_to_4=>total_line_b}
    result[:line_c] = {:unpaid_balance_of_special_assessments=>unpaid_balance_of_special_assessments}
    result[:line_d] = {:total_line_b_plus_line_c=>line_d}
    result[:line_e] = {:line_a_minus_line_d=>line_e}
    result
  end
  
  protected
  
  def attributes
    ATTRIBUTES.inject({}) do |result, key|
      result[key] = send(key)
      result
    end
  end
  
  def attributes=(attrs)
    attrs.each_pair {|k, v| send("#{k}=", v)}
  end
  
end
