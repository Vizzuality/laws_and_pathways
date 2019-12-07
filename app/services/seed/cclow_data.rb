require "#{Rails.root}/lib/timed_logger"

module Seed
  class CCLOWData
    include Singleton

    class << self
      delegate :call, to: :instance
    end

    def call
      ### import Laws ###
      TimedLogger.log('Import legislation') do
        CSVImport::Legislations.new(seed_file('legislation.csv'), override_id: true).call
      end
      # update responses from data
      TimedLogger.log('Fill in responses for laws') do
        Migration::Legislation.fill_responses
      end
      # import source links
      # import instruments
      # import hazards

      ### /Laws ###

      ### import Litigations ###
      TimedLogger.log('Import Litigations') do
        CSVImport::Litigations.new(seed_file('litigations.csv'), override_id: true).call
      end
      # litigation sides
      # sources links
      ### /Litigations

      ### import targets ###
      ### /targets

      ### import events ###
    end

    private

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', 'laws_migration', filename), 'r')
    end
  end
end
