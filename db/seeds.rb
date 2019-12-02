require "#{Rails.root}/lib/timed_logger"

# admin users
# envs: DEV
if Rails.env.development? && !AdminUser.find_by(email: 'admin@example.com')
  AdminUser.create!(
    email: 'admin@example.com',
    password: 'password', password_confirmation: 'password',
    role: 'super_user'
  )
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
  TPISector.find_or_create_by!(name: sector_name) do |sector|
    sector.cp_unit = sector_cp_unit
  end
end

# instruments: Instrument Type & Instrument
# envs: ALL
# rubocop:disable Style/WordArray
[
  ['Capacity-building', ['Knowledge generation',
                         'Sharing and dissemination',
                         'Research and development',
                         'Education and training']],
  ['Regulation', ['Standards and obligations',
                  'Building codes',
                  'Zoning and spatial planning',
                  'Disclosure obligations']],
  ['Incentives', ['Taxes', 'Subsidies']],
  ['Governance and planning', ['Creating bodies/institutions',
                               'Designing processes',
                               'Developing plans and strategies',
                               'Assigning responsibilities to other levels of government',
                               'Monitoring and evaluation']],
  ['Direct investment', ['Public goods - early warning systems',
                         'Public goods - other',
                         'Social safety nets',
                         'Provision of climate finance']]
].each do |inst_type, instruments|
  type = InstrumentType.find_or_create_by!(name: inst_type)
  instruments.each do |inst|
    Instrument.find_or_create_by!(name: inst, instrument_type: type)
  end
end
# rubocop:enable Style/WordArray

# Laws sectors: Names
# envs: ALL
[
  'Agriculture',
  'Residential and Commercial',
  'Coastal zones',
  'Economy-wide',
  'Energy',
  'Health',
  'Industry',
  'LULUCF',
  'Social development',
  'Tourism',
  'Transportation',
  'Urban',
  'Waste',
  'Water',
  'Rural',
  'Environment',
  'Other'
].each do |sector|
  LawsSector.find_or_create_by!(name: sector)
end

def seed_file(filename)
  File.open(Rails.root.join('db', 'seeds', filename), 'r')
end

if Rails.env.development? || ENV['SEED_DATA']
  # import geographies
  TimedLogger.log('Import geographies') do
    CSVImport::Geographies.new(seed_file('geographies.csv')).call
  end

  Seed::TPIData.call

  # import Legislations
  TimedLogger.log('Import Legislations') do
    CSVImport::Legislations.new(seed_file('legislations.csv'), override_id: true).call
  end

  TimedLogger.log('Import Litigations') do
    # import Litigations
    CSVImport::Litigations.new(seed_file('litigations.csv'), override_id: true).call
    # import Litigation Sides
    CSVImport::LitigationSides.new(seed_file('litigation-sides.csv')).call
  end
end
