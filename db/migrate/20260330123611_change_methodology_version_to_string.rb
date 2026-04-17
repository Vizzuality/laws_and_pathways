class ChangeMethodologyVersionToString < ActiveRecord::Migration[6.1]
  def up
    change_column :mq_assessments, :methodology_version, :string, null: false
  end

  def down
    change_column :mq_assessments, :methodology_version, :integer, null: false,
                  using: 'methodology_version::integer'
  end
end
