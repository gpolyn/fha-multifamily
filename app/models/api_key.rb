class ApiKey < ActiveRecord::Base
  
  MAXIMUM_USAGE = 50
  
  validates :times_used, :numericality=>{:only_integer => true, :greater_than_or_equal_to => 0,
                                         :less_than_or_equal_to => MAXIMUM_USAGE}
  validates :value, :length=>{:minimum=>16}
  
  def uses_remaining
    MAXIMUM_USAGE - times_used
  end
  
  def get_uses_remaining_and_increment_times_used_by_1
    remaining = uses_remaining
    self.times_used += 1
    remaining
  end
  
  def self.get_instance
    self.new :value=> generate_key, :times_used=> 0
  end
  
  def self.generate_key
    Digest::SHA1.hexdigest("#{rand(64)}--#{Time.now}")[1..16]
  end
  
end
