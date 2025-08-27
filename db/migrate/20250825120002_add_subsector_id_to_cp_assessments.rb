class AddSubsectorIdToCPAssessments < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_assessments, :subsector_id, :bigint
    add_foreign_key :cp_assessments, :subsectors
  end
end
