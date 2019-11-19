class RenameCoreObjectiveToAtIssue < ActiveRecord::Migration[5.2]
  def change
    rename_column :litigations, :core_objective, :at_issue
  end
end
