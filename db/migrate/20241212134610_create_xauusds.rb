class CreateXauusds < ActiveRecord::Migration[7.1]
  def change
    create_table :xauusds do |t|
      t.date :date, null: false
      t.time :timestamp, null: false
      t.decimal :open, precision: 15, scale: 6, null: false
      t.decimal :high, precision: 15, scale: 6, null: false
      t.decimal :low, precision: 15, scale: 6, null: false
      t.decimal :close, precision: 15, scale: 6, null: false
      t.decimal :volume, precision: 15, scale: 8, null: false

      t.timestamps
    end

    # Adaugă un index simplu pentru coloanele date și timestamp
    add_index :xauusds, [:date, :timestamp]
  end
end

