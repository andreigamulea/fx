class UpdateIndexOnBtcs < ActiveRecord::Migration[7.1]
  def change
    # Elimină indexul unic existent
    if index_exists?(:btcs, [:date, :timestamp], unique: true)
      remove_index :btcs, column: [:date, :timestamp]
    end

    # Adaugă un index non-unique pe [:date, :timestamp]
    add_index :btcs, [:date, :timestamp]
  end
end
