class DropTestimonials < ActiveRecord::Migration[6.0]
  def change
    drop_table :testimonials do |t|
      t.string :quote
      t.string :author
      t.string :role

      t.timestamps
    end
  end
end
