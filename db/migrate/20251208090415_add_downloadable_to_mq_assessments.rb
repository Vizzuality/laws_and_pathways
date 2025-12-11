class AddDownloadableToMQAssessments < ActiveRecord::Migration[6.1]
  def change
    add_column :mq_assessments, :downloadable, :string, default: 'Yes'
  end
end
