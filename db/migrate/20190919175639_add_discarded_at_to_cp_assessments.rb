class AddDiscardedAtToCpAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :cp_assessments, :discarded_at, :datetime
    add_index :cp_assessments, :discarded_at
  end
end
