require "#{Rails.root}/lib/timed_logger"

module Seed
  class CCLOWData
    include Singleton

    class << self
      delegate :call, to: :instance
      delegate :import_litigation_sides, to: :instance
    end

    def call
      ### import Laws ###
      TimedLogger.log('Import legislation') do
        CSVImport::Legislations.new(seed_file('legislation.csv'), override_id: true).call
      end
      ### import Litigations ###
      TimedLogger.log('Import Litigations') do
        CSVImport::Litigations.new(seed_file('litigations.csv'), override_id: true).call
      end

      import_litigation_sides

      ### /Litigations

      ### import targets ###
      TimedLogger.log('Import targets') do
        CSVImport::Targets.new(seed_file('targets.csv'), override_id: true).call
      end
      ### /targets

      ### import events ###
      TimedLogger.log('Import events') do
        CSVImport::Events.new(seed_file('events.csv'), override_id: true).call
      end
    end

    def import_litigation_sides
      TimedLogger.log('Import Litigations Sides') do
        CSVImport::LitigationSides.new(seed_file('litigations-sides.csv')).call
      end
    end

    private

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', 'cclow', filename), 'r')
    end
  end
end
