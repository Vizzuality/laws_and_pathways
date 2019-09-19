class AddDiscardedAtToMqAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :mq_assessments, :discarded_at, :datetime
    add_index :mq_assessments, :discarded_at
  end
end
