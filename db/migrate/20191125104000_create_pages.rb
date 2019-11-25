class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.string :title
      t.text :description
      t.string :slug

      t.timestamps
    end
  end
end
