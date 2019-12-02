require "#{Rails.root}/lib/timed_logger"

module Seed
  class TPIData
    include Singleton

    class << self
      delegate :call, to: :instance
    end

    def call
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
  end
end
