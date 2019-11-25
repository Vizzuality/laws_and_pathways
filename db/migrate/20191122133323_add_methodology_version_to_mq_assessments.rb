class AddMethodologyVersionToMQAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :mq_assessments, :methodology_version, :integer
  end
end
