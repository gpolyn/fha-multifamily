module SelectSec223fValidations
  extend ActiveSupport::Concern
  include ActiveModel::Validations
  
  included do
    validate :metropolitan_area_waiver_is_non_blank_string
    validates :annual_replacement_reserve_per_unit, 
              :numericality => {:greater_than_or_equal_to=>250}
    validate :affordability_is_non_blank_string
  end
  
  attr_accessor :affordability, :metropolitan_area_waiver, :annual_replacement_reserve_per_unit
  
  def initialize(args={})
    self.attributes = args
  end
  
  protected
  
  def attributes=(attrs)
    attrs.each_pair {|k, v| send("#{k}=", v)}
  end
  
  private
  
  def metropolitan_area_waiver_is_non_blank_string
    unless metropolitan_area_waiver && metropolitan_area_waiver.is_a?(String) && metropolitan_area_waiver.size > 0
      errors.add(:metropolitan_area_waiver, "is not a positive-length string")
    end
  end
  
  def affordability_is_non_blank_string
    unless affordability && affordability.is_a?(String) && affordability.size > 0
      errors.add(:affordability, "is not a positive-length string")
    end  
  end
  
end