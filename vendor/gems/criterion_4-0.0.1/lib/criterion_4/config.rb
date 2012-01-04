class Criterion4::StatutoryMortgageLimits
  class << self 
    attr_accessor :non_elevator_0_bedrooms, :non_elevator_1_bedrooms, :non_elevator_2_bedrooms,
                  :non_elevator_3_bedrooms, :non_elevator_4_plus_bedrooms, :elevator_0_bedrooms,
                  :elevator_1_bedrooms, :elevator_2_bedrooms, :elevator_3_bedrooms, 
                  :elevator_4_plus_bedrooms, :per_space
    alias :elevator_4_bedrooms :elevator_4_plus_bedrooms
    alias :non_elevator_4_bedrooms :non_elevator_4_plus_bedrooms
  end
end