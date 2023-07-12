class MakeCPAssessmentPolymorphic < ActiveRecord::Migration[6.0]
  def change
    add_reference :cp_assessments, :cp_assessmentable, polymorphic: true, index: {name: 'index_cp_assessments_on_cp_assessmentable'}
    execute "UPDATE cp_assessments SET cp_assessmentable_id = company_id, cp_assessmentable_type = 'Company'"
    remove_reference :cp_assessments, :company
  end
end
