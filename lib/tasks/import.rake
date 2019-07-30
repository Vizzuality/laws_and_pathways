namespace :import do
  desc 'Import All'
  task all: :environment do
    Rake::Task['import:locations'].invoke
    Rake::Task['import:companies'].invoke
    Rake::Task['import:cp_benchmarks'].invoke
    Rake::Task['import:legislation'].invoke
    Rake::Task['import:litigations'].invoke
  end

  desc 'Imports Locations'
  task locations: :environment do
    TimedLogger.log('import Locations') do
      Import::Locations.new.call
    end
  end

  desc 'Imports Companies'
  task companies: :environment do
    TimedLogger.log('import Companies') do
      Import::Companies.new.call
    end
  end

  desc 'Imports Legislation'
  task legislation: :environment do
    TimedLogger.log('import Legislation') do
      Import::Legislation.new.call
    end
  end

  desc 'Imports CP Benchmarks'
  task cp_benchmarks: :environment do
    TimedLogger.log('import CP benchmarks') do
      Import::CPBenchmarks.new.call
    end
  end

  desc 'Imports Litigations'
  task litigations: :environment do
    TimedLogger.log('import Litigations') do
      Import::Litigations.new.call
    end
  end
end
