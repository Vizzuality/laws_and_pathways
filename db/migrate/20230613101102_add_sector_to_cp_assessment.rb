class AddSectorToCPAssessment < ActiveRecord::Migration[6.0]
  def change
    add_reference :cp_assessments, :sector, foreign_key: { to_table: :tpi_sectors }
  end
end
