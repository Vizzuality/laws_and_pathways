class AddLegislationTypeToLegislation < ActiveRecord::Migration[5.2]
  def change
    # at this stage, no production yet and the development data on staging should be reimported anyway
    add_column :legislations, :legislation_type, :string, null: false, default: 'legislative'
    change_column_default(:legislations, :legislation_type, from: 'legislative', to: nil)
  end
end
