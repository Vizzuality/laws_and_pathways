require "#{Rails.root}/lib/timed_logger"

module Seed
  class CCLOWData
    include Singleton

    class << self
      delegate :call, to: :instance
    end

    def call
      # import companies
      TimedLogger.log('Import companies') do
        CSVImport::Legislations.new(seed_file('legislation.csv'), override_id: true).call
      end
    end

    private

    def seed_file(filename)
      File.open(Rails.root.join('db', 'seeds', 'laws_migration', filename), 'r')
    end
  end
end
