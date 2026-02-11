class AddCompositeIndexToMQAssessments < ActiveRecord::Migration[6.1]
  def change
    add_index :mq_assessments,
      [:discarded_at, :downloadable, :company_id, :methodology_version, :publication_date],
      name: 'index_mq_assessments_on_download_query'
  end
end

