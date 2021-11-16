class AddMQAssessmentsMethodologyVersionNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :mq_assessments, :methodology_version, false
  end
end
