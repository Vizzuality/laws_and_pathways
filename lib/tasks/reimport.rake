namespace :reimport do
  desc 'Reimport TPI data - USE WITH CAUTION'
  task tpi: :environment do
    Company.delete_all
    CP::Assessment.delete_all
    MQ::Assessment.delete_all
    CP::Benchmark.delete_all

    Seed::TPIData.call
  end

  desc 'Reimport CCLOW data - USE WITH CAUTION'
  task cclow: :environment do
    Document.delete_all
    Legislation.delete_all
    Keyword.delete_all
    Framework.delete_all
    NaturalHazard.delete_all
    DocumentType.delete_all
    Response.delete_all
    LitigationSide.delete_all
    Litigation.delete_all
    Target.delete_all
    Event.delete_all

    Seed::CCLOWData.call
  end
end
