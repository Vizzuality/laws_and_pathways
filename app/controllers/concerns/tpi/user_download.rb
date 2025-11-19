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

      latest_cp_assessments_csv = CSVExport::User::CompanyLatestAssessments.new(mq_assessments, cp_assessments).call
      latest_cp_assessments_beta_csv = CSVExport::User::CompanyLatestAssessments.new(
        mq_assessments, cp_assessments, enable_beta_mq_assessments: true
      ).call
      cp_assessments_csv = CSVExport::User::CompanyCPAssessments.new(cp_assessments).call
      cp_assessments_regional_csv = CSVExport::User::CompanyCPAssessmentsRegional.new(cp_assessments).call
      sector_benchmarks_csv = CSVExport::User::CPBenchmarks.new(cp_benchmarks).call
      user_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'User guide TPI files.xlsx'))

      files = (mq_assessments_files || {}).merge(
        'Company_Latest_Assessments.csv' => latest_cp_assessments_csv,
        "CP_Assessments_#{timestamp}.csv" => cp_assessments_csv,
        "CP_Assessments_Regional_#{timestamp}.csv" => cp_assessments_regional_csv,
        "Sector_Benchmarks_#{timestamp}.csv" => sector_benchmarks_csv,
        'User guide TPI files.xlsx' => user_guide
      )
      if ENV['MQ_BETA_ENABLED'].to_s == 'true'
        files = files.merge 'Company_Latest_Assessments_5.0.csv' => latest_cp_assessments_beta_csv
      end
      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end

    def send_tpi_cp_file(cp_assessments:, filename:)
      timestamp = Time.now.strftime('%d%m%Y')
      cp_benchmarks = CP::Benchmark
        .companies
        .joins(:sector)
        .order('tpi_sectors.name ASC, release_date DESC')
        .includes(sector: [:cp_units])

      cp_assessments_csv = CSVExport::User::CompanyCPAssessments.new(cp_assessments).call
      cp_assessments_regional_csv = CSVExport::User::CompanyCPAssessmentsRegional.new(cp_assessments).call
      sector_benchmarks_csv = CSVExport::User::CPBenchmarks.new(cp_benchmarks).call
      user_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'User guide TPI files.xlsx'))

      files = {
        "CP_Assessments_#{timestamp}.csv" => cp_assessments_csv,
        "CP_Assessments_Regional_#{timestamp}.csv" => cp_assessments_regional_csv,
        "Sector_Benchmarks_#{timestamp}.csv" => sector_benchmarks_csv,
        'User guide TPI files.xlsx' => user_guide
      }

      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end

    def send_tpi_mq_file(mq_assessments:, filename:)
      timestamp = Time.now.strftime('%d%m%Y')
      mq_assessments_by_methodology = mq_assessments.group_by(&:methodology_version)

      mq_assessments_files = mq_assessments_by_methodology.map do |methodology, assessments|
        {
          "MQ_Assessments_Methodology_#{methodology}_#{timestamp}.csv" => CSVExport::User::MQAssessments.new(assessments).call
        }
      end.reduce(&:merge)

      user_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'User guide TPI files.xlsx'))

      files = (mq_assessments_files || {}).merge(
        'User guide TPI files.xlsx' => user_guide
      )

      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end
  end
end
