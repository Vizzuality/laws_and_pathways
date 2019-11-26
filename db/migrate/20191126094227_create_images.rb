class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.string :link
      t.references :content, null: false, foreign_key: true
    end
  end
end
