class AddSectorToCPAssessments < ActiveRecord::Migration[6.0]
  def change
    add_reference :cp_assessments, :sector, foreign_key: { to_table: :tpi_sectors }
    add_column :cp_assessments, :final_disclosure_year, :integer, null: true

    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE cp_assessments
      SET sector_id = companies.sector_id
      FROM companies
      WHERE cp_assessments.cp_assessmentable_id = companies.id AND cp_assessments.cp_assessmentable_type = 'Company'
    SQL
  end
end
