class CreateSec223fOccupancyConstraintSets < ActiveRecord::Migration
  def change
    create_table :sec223f_occupancy_constraint_sets do |t|
      t.decimal :minimum_residential_occupancy_percent, :precision =>5, :scale =>2
      t.decimal :maximum_commercial_occupancy_percent, :precision =>5, :scale =>2
      t.decimal :maximum_market_rate_residential_occupancy_percent, :precision =>5, :scale =>2
      t.decimal :maximum_affordable_residential_occupancy_percent, :precision =>5, :scale =>2
      t.timestamps
    end
  end
end
