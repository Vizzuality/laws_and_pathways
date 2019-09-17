# admin users
# envs: DEV
if Rails.env.development? && !AdminUser.find_by(email: 'admin@example.com')
  AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
end

# sectors: names & CP benchmarks units (optional)
# envs: ALL
[
  ['Airlines', 'gCO2 / passenger-kilometre (pkm)'],
  ['Aluminium', 'tCO2e / t aluminium'],
  ['Autos', 'Average new vehicle emissions (grams of CO2 per kilometre [NEDC])'],
  ['Cement', 'Carbon intensity (tonnes of CO2 per tonne of cementitious product)'],
  ['Coal Mining'],
  ['Consumer Goods'],
  ['Electricity Utilities', 'Carbon intensity (metric tonnes of CO2 per MWh electricity generation)'],
  ['Oil & Gas Distribution'],
  ['Oil & gas'],
  ['Other Basic Materials'],
  ['Other Industrials'],
  ['Paper', 'Carbon intensity (tonnes of CO2 per tonne of pulp, paper and paperboard)'],
  ['Services'],
  ['Steel', 'Carbon intensity (tonnes of CO2 per tonne of steel)']
].each do |sector_name, sector_cp_unit|
  sector = Sector.find_or_create_by!(name: sector_name)
  sector.update!(cp_unit: sector_cp_unit) if sector.new_record? && sector_cp_unit.present?
end
