class CreateCPMatrices < ActiveRecord::Migration[6.0]
  def change
    create_table :cp_matrices do |t|
      t.references :cp_assessment, null: false, foreign_key: true
      t.string :portfolio, null: false
      t.string :cp_alignment_2025
      t.string :cp_alignment_2035
      t.string :cp_alignment_2050

      t.timestamps
    end
  end
end
