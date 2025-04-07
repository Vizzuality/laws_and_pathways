class AddCoalMiningCPUnit < ActiveRecord::Migration[6.1]
  def change
    coal_mining_sector = TPISector.where(name: 'Coal Mining').first
    CP::Unit.create!(sector_id: coal_mining_sector.id, unit: 'Indexed CO2e emissions (2021 = 100%)')
  end
end
