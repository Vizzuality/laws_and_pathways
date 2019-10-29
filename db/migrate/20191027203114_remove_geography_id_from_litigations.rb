class RemoveGeographyIdFromLitigations < ActiveRecord::Migration[5.2]
  def change
    remove_reference :litigations, :geography, foreign_key: {on_delete: :cascade}, index: true
  end
end
