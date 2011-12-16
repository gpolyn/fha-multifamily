class CreateHighCostPercentages < ActiveRecord::Migration
  def change
    create_table :high_cost_percentages do |t|
      t.string :city
      t.string :state_abbreviation
      t.integer :value
      t.string :regional_office_city
      t.string :regional_office_state_abbreviation
      t.string :cbsa_code
      t.timestamps
    end
  end
end
