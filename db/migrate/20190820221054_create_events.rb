class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :eventable, polymorphic: true, index: true
      t.string :title, null: false
      t.string :event_type, null: false
      t.date :date, null: false
      t.text :url
      t.text :description
    end
  end
end
