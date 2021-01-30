require "#{Rails.root}/lib/timed_logger"

module Seed
  class TPIData
    include Singleton

    class << self
      delegate :call, :import_sector_clusters, to: :instance
    end

    def call
      import_sectors
      import_sector_clusters

      # import companies
      TimedLogger.log('Import companies') do
        run_importer CSVImport::Companies.new(seed_file('tpi-companies.csv'), override_id: true)
      end

      # import CP Benchmarks
      TimedLogger.log('Import CP Benchmarks') do
        run_importer CSVImport::CPBenchmarks.new(seed_file('cp-benchmarks.csv'))
      end

      # import CP Assessments
      TimedLogger.log('Import CP Assessments') do
        run_importer CSVImport::CPAssessments.new(seed_file('cp-assessments.csv'))
      end

      # import MQ Assessments
      TimedLogger.log('Import MQ Assessments') do
        run_importer CSVImport::MQAssessments.new(seed_file('mq-assessments-M1.csv'))
        run_importer CSVImport::MQAssessments.new(seed_file('mq-assessments-M2.csv'))
        run_importer CSVImport::MQAssessments.new(seed_file('mq-assessments-M3.csv'))
      end
    end

    def import_sector_clusters
      cluster_map = {
        'Aluminium' => 'Industrials and Materials',
        'Cement' => 'Industrials and Materials',
        'Steel' => 'Industrials and Materials',
        'Paper' => 'Industrials and Materials',
        'Electricity Utilities' => 'Energy',
        'Oil & Gas' => 'Energy',
        'Airlines' => 'Transport',
        'Autos' => 'Transport',
        'Shipping' => 'Transport'
      }.freeze

      cluster_map.each do |sector_name, cluster_name|
        sector = TPISector.find_by(name: sector_name)

        next unless sector.present?

        sector.update(
          cluster: TPISectorCluster.find_or_create_by!(name: cluster_name)
        )
      end
    end

    private

    def run_importer(importer)
      importer.call
      puts importer.import_results
    end

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', 'tpi', filename), 'r')
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
        next unless sector_cp_unit.present?

        TPISector.find_or_create_by!(name: sector_name) do |sector|
          sector.cp_units.build(unit: sector_cp_unit) unless sector.latest_cp_unit.present?
        end
      end
    end
  end
end
