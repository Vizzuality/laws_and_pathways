class AddSteelCompaniesSubsector < ActiveRecord::Migration[6.1]
  def up
    steel_sector = TPISector.find_by(name: 'Steel')
    return puts "Warning: Steel sector not found." unless steel_sector

    subsectors = ['Global', 'Primary Steel', 'Secondary Steel']
    Company.where(sector_id: steel_sector.id).find_each do |company|
      subsectors.each do |subsector|
        CompanySubsector.find_or_create_by!(company: company, subsector: subsector)
      end
    end
  end

  def down
    steel_sector = TPISector.find_by(name: 'Steel')
    return unless steel_sector

    company_ids = Company.where(sector_id: steel_sector.id).pluck(:id)
    CompanySubsector.where(company_id: company_ids, subsector: ['Global', 'Primary Steel', 'Secondary Steel']).destroy_all
  end
end
