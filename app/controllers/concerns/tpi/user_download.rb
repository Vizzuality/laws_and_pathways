module TPI
  module UserDownload
    extend ActiveSupport::Concern

    def send_tpi_user_file(mq_assessments:, cp_assessments:, filename:)
      timestamp = Time.now.strftime('%d%m%Y')
      mq_assessments_by_methodology = mq_assessments.group_by(&:methodology_version)
      cp_benchmarks = CP::Benchmark
        .companies
        .joins(:sector)
        .order('tpi_sectors.name ASC, release_date DESC')
        .includes(sector: [:cp_units])

      mq_assessments_files = mq_assessments_by_methodology.map do |methodology, assessments|
        {
          "MQ_Assessments_Methodology_#{methodology}_#{timestamp}.csv" => CSVExport::User::MQAssessments.new(assessments).call
        }
      end.reduce(&:merge)

      timestamp = Time.now.strftime('%d%m%Y')

      cp_assessments_csv = CSVExport::User::CompanyCPAssessments.new(cp_assessments).call
      cp_assessments_regional_csv = CSVExport::User::CompanyCPAssessmentsRegional.new(cp_assessments).call
      sector_benchmarks_csv = CSVExport::User::CPBenchmarks.new(cp_benchmarks).call
      user_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'User guide TPI files.xlsx'))

      files = (mq_assessments_files || {}).merge(
        "CP_Assessments_#{timestamp}.csv" => cp_assessments_csv,
        "CP_Assessments_Regional_#{timestamp}.csv" => cp_assessments_regional_csv,
        "Sector_Benchmarks_#{timestamp}.csv" => sector_benchmarks_csv,
        'User guide TPI files.xlsx' => user_guide
      )
      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end

    def send_tpi_cp_file(cp_assessments:, filename:)
      timestamp = Time.now.strftime('%d%m%Y')
      cp_benchmarks = CP::Benchmark
        .companies
        .joins(:sector)
        .order('tpi_sectors.name ASC, release_date DESC')
        .includes(sector: [:cp_units])

      latest_cp_assessments_csv = CSVExport::User::LatestCPAssessments.new(cp_assessments).call
      cp_assessments_csv = CSVExport::User::CompanyCPAssessments.new(cp_assessments).call
      cp_assessments_regional_csv = CSVExport::User::CompanyCPAssessmentsRegional.new(cp_assessments).call
      sector_benchmarks_csv = CSVExport::User::CPBenchmarks.new(cp_benchmarks).call
      user_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'User guide - TPI Carbon Performance.xlsx'))

      files = {
        'Latest_CP_Assessments.csv' => latest_cp_assessments_csv,
        "CP_Assessments_#{timestamp}.csv" => cp_assessments_csv,
        "CP_Assessments_Regional_#{timestamp}.csv" => cp_assessments_regional_csv,
        "Sector_Benchmarks_#{timestamp}.csv" => sector_benchmarks_csv,
        'User guide - TPI Carbon Performance.xlsx' => user_guide
      }

      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end

    def send_tpi_mq_file(mq_assessments:, filename:)
      timestamp = Time.now.strftime('%d%m%Y')
      mq_assessments_by_methodology = mq_assessments.group_by(&:methodology_version).sort_by { |k, _| k }

      latest_mq_assessments_csv = CSVExport::User::LatestMQAssessments.new(mq_assessments).call

      mq_assessments_files = mq_assessments_by_methodology.map do |methodology, assessments|
        {
          "MQ_Assessments_v#{methodology}_#{timestamp}.csv" => CSVExport::User::MQAssessments.new(assessments).call
        }
      end.reduce(&:merge)

      user_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'User guide - TPI Management Quality.xlsx'))

      files = {
        'Latest_MQ_Assessments.csv' => latest_mq_assessments_csv
      }.merge(mq_assessments_files || {}).merge(
        'User guide - TPI Management Quality.xlsx' => user_guide
      )

      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end
  end
end
