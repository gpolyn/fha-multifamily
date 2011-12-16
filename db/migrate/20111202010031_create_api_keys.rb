class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :value
      t.integer :times_used, :default=>0
      t.timestamps
    end
  end
end
