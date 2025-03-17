class AddCompanySubsectorIdToCPAssessment < ActiveRecord::Migration[6.1]
  def change
    add_column :cp_assessments, :company_subsector_id, :bigint
  end
end
