namespace :reimport do
  desc 'Reimport TPI data - USE WITH CAUTION'
  task tpi: :environment do
    Company.delete_all
    CP::Assessment.delete_all
    MQ::Assessment.delete_all
    CP::Benchmark.delete_all

    Seed::TPIData.call
  end
end
