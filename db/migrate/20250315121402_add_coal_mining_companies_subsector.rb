class AddCoalMiningCompaniesSubsector < ActiveRecord::Migration[6.1]
  def change
    coal_mining_sector_id = TPISector.where(name: 'Coal Mining').first.id
    coal_mining_companies = Company.where(sector_id: coal_mining_sector_id)
    subsectors = ['Thermal Coal', 'Metallurgical Coal']
    coal_mining_companies.each do |company|
      subsectors.each do |subsector|
        CompanySubsector.create(company: company, subsector: subsector)
      end
    end
  end
end
