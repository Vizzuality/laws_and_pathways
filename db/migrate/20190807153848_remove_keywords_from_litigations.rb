class RemoveKeywordsFromLitigations < ActiveRecord::Migration[5.2]
  def change
    remove_column :litigations, :keywords, :text
  end
end
