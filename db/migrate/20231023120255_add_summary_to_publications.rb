class AddSummaryToPublications < ActiveRecord::Migration[6.1]
  def change
    add_column :publications, :summary, :text
  end
end
