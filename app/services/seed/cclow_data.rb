require "#{Rails.root}/lib/timed_logger"

module Seed
  class CCLOWData
    include Singleton

    class << self
      delegate :call, to: :instance
      delegate :import_litigation_sides, to: :instance
    end

    def call
      TimedLogger.log('Import legislation') do
        run_importer CSVImport::Legislations.new(seed_file('legislations.csv'), override_id: true)
      end
      TimedLogger.log('Import Litigations') do
        run_importer CSVImport::Litigations.new(seed_file('litigations.csv'), override_id: true)
      end
      import_litigation_sides
      TimedLogger.log('Import External Laws') do
        run_importer CSVImport::ExternalLegislations.new(seed_file('external-legislations.csv'), override_id: true)
      end
      TimedLogger.log('Import documents') do
        run_importer CSVImport::Documents.new(seed_file('documents.csv'))
      end

      TimedLogger.log('Import targets') do
        run_importer CSVImport::Targets.new(seed_file('targets.csv'), override_id: true)
      end
      TimedLogger.log('Import events') do
        run_importer CSVImport::Events.new(seed_file('events.csv'))
      end
    end

    def import_litigation_sides
      TimedLogger.log('Import Litigations Sides') do
        run_importer CSVImport::LitigationSides.new(seed_file('litigation-sides.csv'))
      end
    end

    private

    def run_importer(importer)
      importer.call
      puts importer.import_results
    end

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', 'cclow', filename), 'r')
    end
  end
end
