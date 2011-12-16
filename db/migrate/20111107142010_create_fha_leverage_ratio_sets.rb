class CreateFhaLeverageRatioSets < ActiveRecord::Migration
  def change
    create_table :fha_leverage_ratio_sets do |t|
      t.decimal :market, :precision =>5, :scale =>2
      t.decimal :affordable, :precision =>5, :scale =>2
      t.decimal :subsidized, :precision =>5, :scale =>2
      t.decimal :cash_out_refinance, :precision =>5, :scale =>2
      t.timestamps
    end
  end
end
