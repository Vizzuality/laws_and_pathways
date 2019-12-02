class CreateTestimonials < ActiveRecord::Migration[6.0]
  def change
    create_table :testimonials do |t|
      t.string :quote
      t.string :author
      t.string :role
      t.bigint :avatar

      t.timestamps
    end
  end
end
