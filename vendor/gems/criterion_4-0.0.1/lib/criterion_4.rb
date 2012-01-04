require 'rubygems'
require "criterion_4/version"
require "criterion_4/config"
require "active_model"
require 'active_support'

# monkey patch rounding, sucker
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

class Boolean
  def self.from_json(value)
    if value.is_a?(TrueClass) || value.is_a?(FalseClass)
      return value
    elsif value.is_a?(String)
      return value == ("true" || "1")
    elsif value.is_a?(Integer)
      return value == 1
    else
      nil
    end
  end
end

module CNA
  # include ActiveModel::Validations
  extend ActiveSupport::Concern
  include ActiveModel::Validations
  
  ATTRIBUTES = [:outdoor_residential_parking_square_feet, 
                :indoor_residential_parking_square_feet,
                :outdoor_commercial_parking_square_feet, 
                :indoor_commercial_parking_square_feet, 
                :outdoor_parking_discount_percent, 
                :gross_apartment_square_feet, :gross_other_square_feet, 
                :gross_commercial_square_feet, :project_value]
                
  attr_accessor *ATTRIBUTES
  
  included do
    # validates :gross_apartment_square_feet, :project_value,
    #           :numericality => {:greater_than_or_equal_to => 0}
    validates :outdoor_residential_parking_square_feet, :indoor_residential_parking_square_feet,
              :outdoor_commercial_parking_square_feet, :indoor_commercial_parking_square_feet, 
              :outdoor_parking_discount_percent, :gross_other_square_feet, :gross_commercial_square_feet,
              :numericality => {:greater_than_or_equal_to => 0, :allow_blank => true}
  end

  
  def initialize(args={})
    self.attributes = args
    self.residential_cna_as_area = 0
    self.commercial_cna_as_area = 0
    self.replacement_cost_area = 0
    self.commercial_cna_as_percentage = 0 
    self.residential_cna_as_percentage = 0
  end
  
  def calculate
    set_areas
    (cna_rate * project_value).round_to(0)
  end
  
  protected
  
  attr_accessor :residential_cna_as_area, :commercial_cna_as_area, :replacement_cost_area, 
                :commercial_cna_as_percentage, :residential_cna_as_percentage
  
  def attributes
    ATTRIBUTES.inject({}) do |result, key|
      result[key] = send(key)
      result
    end
  end
  
  def attributes=(attrs)
    attrs.each_pair {|k, v| send("#{k}=", v)}
  end
  
  private
  
  def cna_rate
    residential_cna_as_percentage = fifteen_percent_or_less_of_total_area residential_cna_as_area
    commercial_cna_as_percentage = fifteen_percent_or_less_of_total_area commercial_cna_as_area
    residential_cna_as_percentage + commercial_cna_as_percentage
  end
                
  def set_areas
    add_apartment_area
    add_parking_areas
    add_commercial_area
    add_other_residential_area
  end
  
  def add_apartment_area
    self.replacement_cost_area = gross_apartment_square_feet.to_f 
  end
  
  def add_other_residential_area
    self.residential_cna_as_area += gross_other_square_feet.to_f
    self.replacement_cost_area += gross_other_square_feet.to_f
  end
  
  def add_commercial_area
    self.commercial_cna_as_area += gross_commercial_square_feet.to_f
    self.replacement_cost_area += gross_commercial_square_feet.to_f
  end
  
  def add_parking_areas
    self.residential_cna_as_area = indoor_residential_parking_square_feet.to_f
    self.residential_cna_as_area += outdoor_residential_parking_square_feet.to_f * 
                                    (100 - outdoor_parking_discount_percent.to_f)/100
    self.commercial_cna_as_area = indoor_commercial_parking_square_feet.to_f
    self.commercial_cna_as_area += outdoor_commercial_parking_square_feet.to_f * 
                                   (100 - outdoor_parking_discount_percent.to_f)/100
    self.replacement_cost_area += residential_cna_as_area + commercial_cna_as_area
  end
  
  def fifteen_percent_or_less_of_total_area(some_constituent_square_footage)
    arg = some_constituent_square_footage.to_f/replacement_cost_area
    arg <= 0.15 ? arg : 0.15
  end
end

class Criterion4::CostNotAttributableWithNoRequiredAttributes
  include CNA
  validates :gross_apartment_square_feet, :project_value,
            :numericality => {:greater_than_or_equal_to => 0, :allow_blank=>true}
  validate :gross_apartment_square_feet_or_project_value_only_nil_when_no_other_attributes
  
  def calculate
    return unless valid? && gross_apartment_square_feet && project_value
    super
  end
  
  protected
  
  def gross_apartment_square_feet_or_project_value_only_nil_when_no_other_attributes
    attrs = ATTRIBUTES - [:project_value, :gross_apartment_square_feet]
    skip = true
    attrs.each {|a| skip = false and break unless self.send(a).nil?}
    
    unless skip
      errors.add(:project_value, "is not a number") unless project_value
      errors.add(:gross_apartment_square_feet, "is not a number") unless gross_apartment_square_feet
    end
  end
end

class Criterion4::CostNotAttributable
  include CNA
  
  validates :gross_apartment_square_feet, :project_value,
            :numericality => {:greater_than_or_equal_to => 0}
  # extend ActiveSupport::Concern
  # include ActiveModel::Validations
  # ATTRIBUTES = [:outdoor_residential_parking_square_feet, 
  #               :indoor_residential_parking_square_feet,
  #               :outdoor_commercial_parking_square_feet, 
  #               :indoor_commercial_parking_square_feet, 
  #               :outdoor_parking_discount_percent, 
  #               :gross_apartment_square_feet, :gross_other_square_feet, 
  #               :gross_commercial_square_feet, :project_value]
  #               
  # attr_accessor *ATTRIBUTES
  # 
  # validates :gross_apartment_square_feet, :project_value,
  #           :numericality => {:greater_than_or_equal_to => 0}
  # validates :outdoor_residential_parking_square_feet, :indoor_residential_parking_square_feet,
  #           :outdoor_commercial_parking_square_feet, :indoor_commercial_parking_square_feet, 
  #           :outdoor_parking_discount_percent, :gross_other_square_feet, :gross_commercial_square_feet,
  #           :numericality => {:greater_than_or_equal_to => 0, :allow_blank => true}
  # 
  # def initialize(args={})
  #   self.attributes = args
  #   self.residential_cna_as_area = 0
  #   self.commercial_cna_as_area = 0
  #   self.replacement_cost_area = 0
  #   self.commercial_cna_as_percentage = 0 
  #   self.residential_cna_as_percentage = 0
  # end
  # 
  # def calculate
  #   set_areas
  #   (cna_rate * project_value).round_to(0)
  # end
  # 
  # protected
  # 
  # attr_accessor :residential_cna_as_area, :commercial_cna_as_area, :replacement_cost_area, 
  #               :commercial_cna_as_percentage, :residential_cna_as_percentage
  # 
  # def attributes
  #   ATTRIBUTES.inject({}) do |result, key|
  #     result[key] = send(key)
  #     result
  #   end
  # end
  # 
  # def attributes=(attrs)
  #   attrs.each_pair {|k, v| send("#{k}=", v)}
  # end
  # 
  # private
  # 
  # def cna_rate
  #   residential_cna_as_percentage = fifteen_percent_or_less_of_total_area residential_cna_as_area
  #   commercial_cna_as_percentage = fifteen_percent_or_less_of_total_area commercial_cna_as_area
  #   residential_cna_as_percentage + commercial_cna_as_percentage
  # end
  #               
  # def set_areas
  #   add_apartment_area
  #   add_parking_areas
  #   add_commercial_area
  #   add_other_residential_area
  # end
  # 
  # def add_apartment_area
  #   self.replacement_cost_area = gross_apartment_square_feet.to_f 
  # end
  # 
  # def add_other_residential_area
  #   self.residential_cna_as_area += gross_other_square_feet.to_f
  #   self.replacement_cost_area += gross_other_square_feet.to_f
  # end
  # 
  # def add_commercial_area
  #   self.commercial_cna_as_area += gross_commercial_square_feet.to_f
  #   self.replacement_cost_area += gross_commercial_square_feet.to_f
  # end
  # 
  # def add_parking_areas
  #   self.residential_cna_as_area = indoor_residential_parking_square_feet.to_f
  #   self.residential_cna_as_area += outdoor_residential_parking_square_feet.to_f * 
  #                                   (100 - outdoor_parking_discount_percent.to_f)/100
  #   self.commercial_cna_as_area = indoor_commercial_parking_square_feet.to_f
  #   self.commercial_cna_as_area += outdoor_commercial_parking_square_feet.to_f * 
  #                                  (100 - outdoor_parking_discount_percent.to_f)/100
  #   self.replacement_cost_area += residential_cna_as_area + commercial_cna_as_area
  # end
  # 
  # def fifteen_percent_or_less_of_total_area(some_constituent_square_footage)
  #   arg = some_constituent_square_footage.to_f/replacement_cost_area
  #   arg <= 0.15 ? arg : 0.15
  # end
  
end

class Criterion4::Criterion4
  
  include ActiveModel::Validations
  
  ATTRIBUTES = [:high_cost_percentage, :is_elevator_project, :number_of_no_bedroom_units, 
                :number_of_one_bedroom_units, :number_of_two_bedroom_units, 
                :number_of_three_bedroom_units, :number_of_four_or_more_bedroom_units,
                :cost_not_attributable_to_dwelling_use, :warranted_price_of_land, :percent_multiplier,
                :total_number_of_spaces, :value_of_leased_fee, :unpaid_balance_of_special_assessments]
                
  attr_accessor *ATTRIBUTES
  
  # alias :line_b :cost_not_attributable_to_dwelling_use
  
  validates :high_cost_percentage, :percent_multiplier, :numericality => {:greater_than_or_equal_to => 0}
  validates :number_of_no_bedroom_units, :number_of_one_bedroom_units, :number_of_two_bedroom_units, 
            :number_of_three_bedroom_units, :number_of_four_or_more_bedroom_units, :total_number_of_spaces,
            :numericality => {:greater_than_or_equal_to => 0, :only_integer => true, :allow_blank => true}
  validates :cost_not_attributable_to_dwelling_use, :warranted_price_of_land,
            :value_of_leased_fee, :unpaid_balance_of_special_assessments,
            :numericality => {:greater_than_or_equal_to => 0, :allow_blank => true}
  validates :is_elevator_project, :inclusion => {:in =>[true, false, nil], :message => "must be one of true, false or nil"}
            
  validate :not_both_of_total_number_of_spaces_and_units_by_any_bedroom_type_present
  validate :if_total_number_of_spaces_blank_then_apartment_units_greater_than_4
  
  def initialize(args={})
    self.attributes = args
  end
  
  [["no", 0], ["one", 1], ["two", 2], ["three", 3], ["four_or_more", 4]].each do |arr|
    define_method "number_of_#{arr.first}_bedroom_units_product" do
      return nil unless units = send("number_of_#{arr.first}_bedroom_units")
      return nil unless dollar_limit = send("dollar_limit_for_#{arr.last}_bedrooms")
      (units * dollar_limit).round_to 2
    end
  end
  
  def line_b
    return nil unless cost_not_attributable_to_dwelling_use && percent_multiplier
    (percent_multiplier.to_f/100 * cost_not_attributable_to_dwelling_use).round_to(2)
  end
  
  def line_c
    return nil unless warranted_price_of_land && percent_multiplier
    (percent_multiplier.to_f/100 * warranted_price_of_land).round_to(2)
  end
  
  def total_lines_a_through_c
    return if unit_products_all_nil && !line_b && !line_c
    total = number_of_no_bedroom_units_product.to_f
    total += number_of_one_bedroom_units_product.to_f
    total += number_of_two_bedroom_units_product.to_f
    total += number_of_three_bedroom_units_product.to_f
    total += number_of_four_or_more_bedroom_units_product.to_f
    total += line_b.to_f
    total += line_c.to_f
  end
  
  alias :line_d :total_lines_a_through_c
  
  def line_e
    return unless total_number_of_spaces 
    return unless Criterion4::StatutoryMortgageLimits.per_space
    return unless high_cost_percentage
    prod = total_number_of_spaces * Criterion4::StatutoryMortgageLimits.per_space 
    prod *= high_cost_percentage.to_f/100
    prod.round_to(2)
  end
  
  def sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments
    return unless value_of_leased_fee || unpaid_balance_of_special_assessments
    value_of_leased_fee.to_f + unpaid_balance_of_special_assessments.to_f
  end
  
  alias :line_f :sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments
  
  def line_d_or_line_e_minus_line_f
    return unless d_or_e = line_d_or_line_e
    ((d_or_e - line_f.to_f)/100).truncate * 100
  end
  
  alias :line_g :line_d_or_line_e_minus_line_f
  
  def as_json(options={})
    result = Hash.new
    result[:line_a] = {:number_of_no_bedroom_units=>{:units=>number_of_no_bedroom_units,
                       :per_family_unit_limit=>dollar_limit_for_0_bedrooms, :total=>number_of_no_bedroom_units_product}}
    result[:line_a][:number_of_one_bedroom_units] = {:units=>number_of_one_bedroom_units,
                                                     :per_family_unit_limit=>dollar_limit_for_1_bedrooms,
                                                     :total=>number_of_one_bedroom_units_product}
    result[:line_a][:number_of_two_bedroom_units] = {:units=>number_of_two_bedroom_units,
                                                     :per_family_unit_limit=>dollar_limit_for_2_bedrooms,
                                                     :total=>number_of_two_bedroom_units_product}
    result[:line_a][:number_of_three_bedroom_units] = {:units=>number_of_three_bedroom_units,
                                                       :per_family_unit_limit=>dollar_limit_for_3_bedrooms,
                                                       :total=>number_of_three_bedroom_units_product}
    result[:line_a][:number_of_four_or_more_bedroom_units] = {:units=>number_of_four_or_more_bedroom_units,
                                                              :per_family_unit_limit=>dollar_limit_for_4_bedrooms,
                                                              :total=>number_of_four_or_more_bedroom_units_product}
    result[:line_b] = {:cost_not_attributable_to_dwelling_use => cost_not_attributable_to_dwelling_use, 
                       :percent_multiplier=>percent_multiplier, :result=>line_b}
    result[:line_c] = {:warranted_price_of_land => warranted_price_of_land, :percent_multiplier=>percent_multiplier, 
                       :result=>line_c}
    result[:line_d] = {:total_lines_a_through_c=>line_d}
    result[:line_e] = {:total_number_of_spaces=>total_number_of_spaces}
    val = sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments
    result[:line_f] = {:sum_value_of_leased_fee_and_unpaid_balance_of_special_assessments=>val}
    result[:line_g] = {:line_d_or_line_e_minus_line_f=>line_d_or_line_e_minus_line_f}
    result
  end
  
  def total_apartments
    return_nil = false
    total = ['no', 'one', 'two', 'three', 'four_or_more'].inject(0) do |total, x|
      units = send("number_of_#{x}_bedroom_units")
      return_nil = true and break unless units.nil? || (units.is_a?(Fixnum) && units >= 0)
      total + units.to_i
    end
    return if return_nil
    total
  end
  
  protected
  
  def if_total_number_of_spaces_blank_then_apartment_units_greater_than_4     
    if total_number_of_spaces.blank? && total_apartments && total_apartments < 5
      add_error_to_each_bedroom_type_unit "must contribute to a total of at least five apartments"
    end
  end
  
  def not_both_of_total_number_of_spaces_and_units_by_any_bedroom_type_present
    return if total_number_of_spaces.blank?
    unless total_apartments == 0
      add_error_to_each_bedroom_type_unit "mutually exclusive with total_number_of_spaces"
      errors.add(:total_number_of_spaces, "mutually exclusive with apartments units of any type")
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
  
  # def attributes=(attrs)
  #   attrs.each_pair do |k, v|
  #     v = if @@float_attributes.include?(k)
  #       v.to_f
  #     elsif @@integer_attributes.include?(k)
  #       v.to_i
  #     elsif @@boolean_attributes.include?(k)
  #       Boolean.from_json v
  #     else
  #       v
  #     end
  #     
  #     send("#{k}=", v)
  #   end
  # end
  
  private
  
  def add_error_to_each_bedroom_type_unit(err_msg)
    [:number_of_two_bedroom_units, :number_of_four_or_more_bedroom_units, :number_of_no_bedroom_units,
     :number_of_three_bedroom_units, :number_of_one_bedroom_units].each {|key| errors.add(key, err_msg)}
  end
  
  def unit_products_all_nil
    !number_of_no_bedroom_units_product && !number_of_one_bedroom_units_product &&
    !number_of_two_bedroom_units_product && !number_of_three_bedroom_units_product &&
    !number_of_four_or_more_bedroom_units_product
  end
  
  (0..4).each do |i|
    define_method "dollar_limit_for_#{i}_bedrooms" do
      return unless high_cost_percentage
      str_to_use = is_elevator_project ? "elevator_#{i}_bedrooms" : "non_elevator_#{i}_bedrooms"
      return unless stat_limits = Criterion4::StatutoryMortgageLimits.send(str_to_use)
      (stat_limits * high_cost_percentage.to_f/100).round_to(2)
    end
  end
  
  def line_d_or_line_e
    line_e || line_d
  end
  
end

class Criterion4::Criterion4AcceptingCNAParameters < Criterion4::Criterion4
  
  ATTRIBUTES = Criterion4::Criterion4::ATTRIBUTES + Criterion4::CostNotAttributable::ATTRIBUTES + [:cna]
  
  attr_accessor *ATTRIBUTES
  
  def initialize(args={})
    args = args.dup
    cna_hash = Criterion4::CostNotAttributable::ATTRIBUTES.inject({}) do |result, ele|
      result[ele] = args[ele]
      result
    end
    
    self.cna = Criterion4::CostNotAttributableWithNoRequiredAttributes.new cna_hash
    args[:cost_not_attributable_to_dwelling_use] = cna.calculate
    self.attributes = args
  end
  
  def valid?
    super and cna.valid?
  end
  
  def errors
    cna.errors.each {|k,v| super.add(k, v) unless super[k] && super[k].include?(v)}
    super
  end
  
end