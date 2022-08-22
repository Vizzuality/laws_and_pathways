class CreateCaseStudies < ActiveRecord::Migration[6.0]
  def change
    create_table :case_studies do |t|
      t.string :organization, null: false
      t.string :link, null: false
      t.string :text, null: false

      t.timestamps
    end
  end
end
