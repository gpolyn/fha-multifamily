module Sec223fMultifamilyStatLimitSetValidations
  extend ActiveSupport::Concern
  include ActiveModel::Validations
  
  included do
    validates :zero_bedroom, :one_bedroom, :two_bedroom, :three_bedroom, :four_bedroom,
              :numericality => {:greater_than_or_equal_to => 0, :only_integer=>true}
  end
  # 11/6/11 - suspended these efforts at consolidating validation -- not quite enough juice!
end