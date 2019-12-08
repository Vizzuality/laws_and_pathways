require "#{Rails.root}/lib/timed_logger"

module Seed
  class CCLOWData
    include Singleton

    class << self
      delegate :call, to: :instance
    end

    # rubocop:disable Metrics/AbcSize
    def call
      ### import Laws ###
      TimedLogger.log('Import legislation') do
        CSVImport::Legislations.new(seed_file('legislation.csv'), override_id: true).call
      end
      TimedLogger.log('Fill in responses for laws') do
        Migration::Legislation.fill_responses
      end
      TimedLogger.log('Migrate source files') do
        Migration::Legislation.migrate_source_files(seed_file('legislation-sources.csv'))
      end
      # import instruments
      # import hazards

      ### import Litigations ###
      TimedLogger.log('Import Litigations') do
        CSVImport::Litigations.new(seed_file('litigations.csv'), override_id: true).call
      end
      TimedLogger.log('Import Litigations Sides') do
        CSVImport::LitigationSides.new(seed_file('litigations-sides.csv')).call
      end
      TimedLogger.log('Migrate litigations source files') do
        Migration::Litigation.migrate_source_files(seed_file('litigation-sources.csv'))
      end
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
    # rubocop:enable Metrics/AbcSize

    private

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', 'laws_migration', filename), 'r')
    end
  end
end
