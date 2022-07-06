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

      TimedLogger.log('Import companies') do
        run_importer CSVImport::Companies.new(seed_file('tpi-companies.csv'), override_id: true)
      end

      TimedLogger.log('Import CP Benchmarks') do
        run_importer CSVImport::CPBenchmarks.new(seed_file('cp-benchmarks.csv'))
      end

      TimedLogger.log('Import CP Assessments') do
        run_importer CSVImport::CPAssessments.new(seed_file('cp-assessments.csv'))
      end

      TimedLogger.log('Import MQ Assessments') do
        run_importer CSVImport::MQAssessments.new(seed_file('mq-assessments-M1.csv'))
        run_importer CSVImport::MQAssessments.new(seed_file('mq-assessments-M2.csv'))
        run_importer CSVImport::MQAssessments.new(seed_file('mq-assessments-M3.csv'))
      end

      TimedLogger.log('Import Bank Data') do
        run_importer CSVImport::Banks.new(seed_file('banks.csv'))
      end

      TimedLogger.log('Import Bank Assessment Indicators') do
        run_importer CSVImport::BankAssessmentIndicators.new(seed_file('bank_assessment_indicators.csv'))
      end

      TimedLogger.log('Import Bank Assessments') do
        run_importer CSVImport::BankAssessments.new(seed_file('bank_assessments.csv'))
      end

      # TimedLogger.log('Import News Articles') do
      #   run_importer CSVImport::NewsArticles.new(seed_file('tpi-news-articles.csv'), allow_tags_adding: true)
      #   random_assign_images_to_articles
      # end

      # TimedLogger.log('Create Publications') do
      #   create_publications
      # end
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

    def random_assign_images_to_articles
      NewsArticle.find_each do |article|
        article.image.attach(attachable_file(random_image_file))
      end
    end

    def create_publications
      Publication.create!(
        title: 'Carbon Performance assessment of airlines: note on methodology',
        publication_date: '2022-02-14',
        short_description: 'Some short description',
        keywords: keywords(%w[Airlines Methodology]),
        file: attachable_file('files/test.pdf'),
        image: attachable_file('files/airlines2022.jpg'),
        created_by: admin_user
      )
      Publication.create!(
        title: 'Carbon performance assessment of international shipping: note on methodology',
        publication_date: '2022-02-10',
        short_description: 'Some short description',
        keywords: keywords(%w[Shipping Methodology]),
        file: attachable_file('files/test.pdf'),
        image: attachable_file('files/shipping2022.jpg'),
        created_by: admin_user
      )
      Publication.create!(
        title: 'Carbon Performance assessment of the automobile manufacturers: note on methodology 2020',
        publication_date: '2022-02-12',
        short_description: 'Some short description',
        keywords: keywords(%w[Autos Methodology]),
        file: attachable_file('files/test.pdf'),
        image: attachable_file('files/autos2022.jpg'),
        created_by: admin_user
      )
    end

    private

    def run_importer(importer)
      puts "Error while running importer: #{importer.errors.full_messages.join(', ')}" unless importer.call
      puts importer.import_results
    end

    def keywords(array)
      array.map { |keyword| Keyword.find_or_create_by!(name: keyword) }
    end

    def admin_user
      @admin_user ||= AdminUser.find_by(email: 'admin@example.com')
    end

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', 'tpi', filename), 'r')
    end

    def random_image_file
      %w[
        files/airlines2022.jpg
        files/autos2022.jpg
        files/bridge.jpg
        files/industrials.jpg
        files/shipping2022.jpg
      ].sample
    end

    def attachable_file(filename)
      {
        io: seed_file(filename),
        filename: File.basename(filename),
        content_type: Marcel::MimeType.for(name: filename)
      }
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
