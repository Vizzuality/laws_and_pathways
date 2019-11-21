require "#{Rails.root}/lib/timed_logger"

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
  sector = TPISector.find_or_create_by!(name: sector_name)
  sector.update!(cp_unit: sector_cp_unit) if sector.new_record? && sector_cp_unit.present?
end

# instruments: Instrument Type & Instrument
# envs: ALL
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

if Rails.env.development? || ENV['SEED_DATA']
  # import geographies
  TimedLogger.log('Import geographies') do
    file = File.open(Rails.root.join('db', 'seeds', 'geographies.csv'), 'r')
    CSVImport::Geographies.new(file).call
  end

  # import companies
  TimedLogger.log('Import companies') do
    file = File.open(Rails.root.join('db', 'seeds', 'companies.csv'), 'r')
    CSVImport::Companies.new(file).call
  end

  # import CP Benchmarks
  TimedLogger.log('Import CP Benchmarks') do
    file = File.open(Rails.root.join('db', 'seeds', 'cp-benchmarks.csv'), 'r')
    CSVImport::CPBenchmarks.new(file).call
  end

  # import CP Assessments
  TimedLogger.log('Import CP Assessments') do
    file = File.open(Rails.root.join('db', 'seeds', 'cp-assessments.csv'), 'r')
    CSVImport::CPAssessments.new(file).call
  end

  # import MQ Assessments
  TimedLogger.log('Import MQ Assessments') do
    file = File.open(Rails.root.join('db', 'seeds', 'mq-assessments-M1.csv'), 'r')
    CSVImport::MQAssessments.new(file).call

    file = File.open(Rails.root.join('db', 'seeds', 'mq-assessments-M2.csv'), 'r')
    CSVImport::MQAssessments.new(file).call
  end

  # import Legislations
  TimedLogger.log('Import Legislations') do
    file = File.open(Rails.root.join('db', 'seeds', 'legislations.csv'), 'r')
    importer = CSVImport::Legislations.new(file)
    importer.override_id = true
    importer.call
    ActiveRecord::Base.connection.execute("select setval('legislations_id_seq',max(id)) from legislations;")
  end

  TimedLogger.log('Import Litigations') do
    # import Litigations
    file = File.open(Rails.root.join('db', 'seeds', 'litigations.csv'), 'r')
    importer = CSVImport::Litigations.new(file)
    importer.override_id = true
    importer.call
    ActiveRecord::Base.connection.execute("select setval('litigations_id_seq',max(id)) from litigations;")

    # import Litigation Sides
    file = File.open(Rails.root.join('db', 'seeds', 'litigation-sides.csv'), 'r')
    CSVImport::LitigationSides.new(file).call
  end
end
