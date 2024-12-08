class CreateUs30s < ActiveRecord::Migration[7.0]
  def change
    create_table :us30s do |t|
      t.date :date, null: false
      t.time :timestamp, null: false
      t.decimal :open, precision: 15, scale: 6, null: false
      t.decimal :high, precision: 15, scale: 6, null: false
      t.decimal :low, precision: 15, scale: 6, null: false
      t.decimal :close, precision: 15, scale: 6, null: false
      t.decimal :volume, precision: 15, scale: 8, null: false

      t.timestamps
    end

    # Adaugă un index pentru performanță
    add_index :us30s, [:date, :timestamp], unique: true
  end
end
