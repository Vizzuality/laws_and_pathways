class RemoveASCORSector < ActiveRecord::Migration[6.1]
  def change
    TPISector.find_by(slug: 'ascor')&.destroy
  end
end
