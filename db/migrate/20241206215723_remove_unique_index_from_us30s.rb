class RemoveUniqueIndexFromUs30s < ActiveRecord::Migration[7.1]
  def change
    # Elimină indexul unic existent
    remove_index :us30s, column: [:date, :timestamp]

    # Adaugă un index simplu (non-unique)
    add_index :us30s, [:date, :timestamp]
  end
end
