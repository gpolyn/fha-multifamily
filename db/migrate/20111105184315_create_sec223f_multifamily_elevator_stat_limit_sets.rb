class CreateSec223fMultifamilyElevatorStatLimitSets < ActiveRecord::Migration
  def change
    create_table :sec223f_multifamily_elevator_stat_limit_sets do |t|
      t.integer :zero_bedroom
      t.integer :one_bedroom
      t.integer :two_bedroom
      t.integer :three_bedroom
      t.integer :four_bedroom
      t.timestamps
    end
  end
end
