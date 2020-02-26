namespace :reimport do
  desc 'Reimport TPI data - USE WITH CAUTION'
  task tpi: :environment do
    Company.delete_all
    CP::Assessment.delete_all
    MQ::Assessment.delete_all
    CP::Benchmark.delete_all

    Seed::TPIData.call
  end

  task tpi_sector_clusters: :environment do
    Seed::TPIData.import_sector_clusters

    puts 'TPI Sector Clusters reimported'
  end

  desc 'Reimport CCLOW data - USE WITH CAUTION'
  task cclow: :environment do
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

  desc 'Reimport CCLOW files data - USE WITH CAUTION'
  task cclow_sources: :environment do
    Document.delete_all

    Seed::CCLOWData.call_sources_import
  end

  desc 'Reimport CCLOW litigation files data only - USE WITH CAUTION'
  task cclow_sources: :environment do
    # let's start by appending
    # Document.delete_all

    Seed::CCLOWData.call_litigation_sources_import
  end

  desc 'Reimport CCLOW LitigationSides'
  task cclow_litigation_sides: :environment do
    LitigationSide.delete_all

    Seed::CCLOWData.import_litigation_sides
  end
end
