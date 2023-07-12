class AddSlugToPublications < ActiveRecord::Migration[6.0]
  def change
    add_column :publications, :slug, :text, null: true
    Publication.find_each(&:save!)
    change_column_null :publications, :slug, false
    add_index :publications, :slug, unique: true
  end
end
