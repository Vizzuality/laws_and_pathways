class RefactorASCORModels < ActiveRecord::Migration[6.1]
  def change
    add_column :ascor_countries, :type_of_party, :string, null: true
  end
end
