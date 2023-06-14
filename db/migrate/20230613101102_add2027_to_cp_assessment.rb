class Add2027ToCPAssessment < ActiveRecord::Migration[6.0]
  def change
    add_column :cp_assessments, :cp_alignment_2027, :string
    add_column :cp_assessments, :cp_regional_alignment_2027, :string
    add_reference :cp_assessments, :sector, foreign_key: { to_table: :tpi_sectors }
  end
end
