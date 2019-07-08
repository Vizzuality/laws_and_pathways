namespace :import do
  desc 'Import All'
  task all: :environment do
    Rake::Task['import:locations'].invoke
    Rake::Task['import:companies'].invoke
    Rake::Task['import:cp_benchmarks'].invoke
  end

  desc 'Imports Locations'
  task locations: :environment do
    TimedLogger.log('import locations') do
      ImportLocations.new.call
    end
  end

  desc 'Imports Companies'
  task companies: :environment do
    TimedLogger.log('import companies') do
      ImportCompanies.new.call
    end
  end

  desc 'Imports CP Benchmarks'
  task cp_benchmarks: :environment do
    TimedLogger.log('import CP benchmarks') do
      ImportCPBenchmarks.new.call
    end
  end
end
