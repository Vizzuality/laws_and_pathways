require "#{Rails.root}/lib/timed_logger"

module Seed
  class TPIData
    include Singleton

    class << self
      delegate :call, to: :instance
    end

    def call
      import_sectors

      # import companies
      TimedLogger.log('Import companies') do
        CSVImport::Companies.new(seed_file('tpi-companies.csv'), override_id: true).call
      end

      # import CP Benchmarks
      TimedLogger.log('Import CP Benchmarks') do
        CSVImport::CPBenchmarks.new(seed_file('cp-benchmarks.csv')).call
      end

      # import CP Assessments
      TimedLogger.log('Import CP Assessments') do
        CSVImport::CPAssessments.new(seed_file('cp-assessments.csv')).call
      end

      # import MQ Assessments
      TimedLogger.log('Import MQ Assessments') do
        CSVImport::MQAssessments.new(seed_file('mq-assessments-M1.csv')).call
        CSVImport::MQAssessments.new(seed_file('mq-assessments-M2.csv')).call
        CSVImport::MQAssessments.new(seed_file('mq-assessments-M3.csv')).call
      end
    end

    private

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', filename), 'r')
    end

    def import_sectors
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
    end
  end
end
