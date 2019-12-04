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

  # import NewsArticles
  # TimedLogger.log('Import news articles') do
  #   CSVImport::NewsArticles.new(seed_file('tpi-news.csv')).call
  # end

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
