class CreateBtcs < ActiveRecord::Migration[7.0]
  def change
    create_table :btcs do |t|
      t.date :date, null: false
      t.time :timestamp, null: false
      t.decimal :open, precision: 15, scale: 6, null: false
      t.decimal :high, precision: 15, scale: 6, null: false
      t.decimal :low, precision: 15, scale: 6, null: false
      t.decimal :close, precision: 15, scale: 6, null: false
      t.decimal :volume, precision: 15, scale: 8, null: false

      t.timestamps
    end

    # Adaugă index pentru performanță
    add_index :btcs, [:date, :timestamp], unique: true
    add_index :btcs, :date
    add_index :btcs, :timestamp
  end
end

