namespace :import do
  desc 'Imports Locations'
  task locations: :environment do
    TimedLogger.log('import locations') do
      ImportLocations.new.call
    end
  end
end
