class HighCostPercentage < ActiveRecord::Base
  validates :value, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :city, :presence => true
  
  def self.get_value(entity)
    location_pair = entity.split(',').map(&:lstrip)
    
    begin
      if location_pair.size == 2
        HighCostPercentage.find_last_by_city_and_state_abbreviation(location_pair.first, location_pair.last).value
      else
        HighCostPercentage.find_last_by_city(location_pair.first).value
      end
    rescue Exception => e
      nil
    end
  end
end
