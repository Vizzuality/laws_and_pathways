require "#{Rails.root}/lib/timed_logger"

# admin users
# envs: DEV
if (Rails.env.development? || Rails.env.test?) && !AdminUser.find_by(email: 'admin@example.com')
  AdminUser.create!(
    email: 'admin@example.com',
    password: 'password', password_confirmation: 'password',
    role: 'super_user'
  )
  AdminUser.create!(
    email: 'publisher_laws@example.com',
    password: 'password', password_confirmation: 'password',
    role: 'publisher_laws'
  )
  AdminUser.create!(
    email: 'publisher_tpi@example.com',
    password: 'password', password_confirmation: 'password',
    role: 'publisher_tpi'
  )
  AdminUser.create!(
    email: 'editor_laws@example.com',
    password: 'password', password_confirmation: 'password',
    role: 'editor_laws'
  )
  AdminUser.create!(
    email: 'editor_tpi@example.com',
    password: 'password', password_confirmation: 'password',
    role: 'editor_tpi'
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

if Rails.env.development? || Rails.env.test? || ENV['SEED_DATA']
  # import geographies
  TimedLogger.log('Import geographies') do
    CSVImport::Geographies.new(seed_file('geographies.csv')).call
  end

  # import NewsArticles
  # TimedLogger.log('Import news articles') do
  #   CSVImport::NewsArticles.new(seed_file('tpi-news.csv')).call
  # end

  Seed::TPIData.call
  Seed::CCLOWData.call
end
