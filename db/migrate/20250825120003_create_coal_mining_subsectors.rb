class CreateCoalMiningSubsectors < ActiveRecord::Migration[6.1]
  def up
    coal_mining_sector = TPISector.find_by(name: 'Coal Mining')
    
    if coal_mining_sector
      Subsector.create!(sector: coal_mining_sector, name: 'Thermal Coal')
      Subsector.create!(sector: coal_mining_sector, name: 'Metallurgical Coal')
    else
      puts "Warning: Coal Mining sector not found. Please create it first."
    end
  end

  def down
    coal_mining_sector = TPISector.find_by(name: 'Coal Mining')
    
    if coal_mining_sector
      Subsector.where(sector: coal_mining_sector, name: ['Thermal Coal', 'Metallurgical Coal']).destroy_all
    end
  end
end
