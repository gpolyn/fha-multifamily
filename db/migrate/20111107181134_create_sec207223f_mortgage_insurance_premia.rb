class CreateSec207223fMortgageInsurancePremia < ActiveRecord::Migration
  def change
    create_table :sec207223f_mortgage_insurance_premia do |t|
      t.decimal :without_lihtc_annual, :precision =>5, :scale =>2
      t.decimal :with_lihtc_annual, :precision =>5, :scale =>2
      t.decimal :without_lihtc_initial, :precision =>5, :scale =>2
      t.decimal :with_lihtc_initial, :precision =>5, :scale =>2
      t.timestamps
    end
  end
end
