class AddTimestampsToImage < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :created_at, :datetime, null: false, default: Time.zone.now
    add_column :images, :updated_at, :datetime, null: false, default: Time.zone.now
  end
end
