class AddSystemTypeToLitigations < ActiveRecord::Migration[5.2]
  def change
    add_column :litigation_sides, :system_type, :string, null: false, default: 'other'
    change_column_default :litigation_sides, :system_type, from: 'other', to: nil
  end
end
