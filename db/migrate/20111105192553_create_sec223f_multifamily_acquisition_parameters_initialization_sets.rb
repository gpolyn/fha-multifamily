class CreateSec223fMultifamilyAcquisitionParametersInitializationSets < ActiveRecord::Migration
  def change
    create_table :sec223f_multifamily_acquisition_parameters_initialization_sets do |t|
      t.decimal :mortgage_interest_rate, :precision =>5, :scale =>2
      t.decimal :financing_fee_as_percent_of_loan, :precision =>5, :scale =>2
      t.integer :financing_fee_in_dollars
      t.integer :legal_and_organizational
      t.decimal :title_and_recording_as_percent_of_loan, :precision=> 6, :scale => 3
      t.integer :title_and_recording_in_dollars
      t.integer :third_party_reports
      t.integer :other
      t.integer :survey
      t.integer :annual_replacement_reserve_per_unit
      t.decimal :exam_fee_rate, :precision =>5, :scale =>2
      t.timestamps
    end
  end
end
