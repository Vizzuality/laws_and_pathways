class CreateSteelSubsectors < ActiveRecord::Migration[6.1]
  def up
    steel_sector = TPISector.find_by(name: 'Steel')

    if steel_sector
      Subsector.create!(sector: steel_sector, name: 'Global')
      Subsector.create!(sector: steel_sector, name: 'Primary Steel')
      Subsector.create!(sector: steel_sector, name: 'Secondary Steel')
    else
      puts "Warning: Steel sector not found. Please create it first."
    end
  end

  def down
    steel_sector = TPISector.find_by(name: 'Steel')

    if steel_sector
      Subsector.where(sector: steel_sector, name: ['Global', 'Primary Steel', 'Secondary Steel']).destroy_all
    end
  end
end
