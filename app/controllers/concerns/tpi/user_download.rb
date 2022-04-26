module TPI
  module UserDownload
    extend ActiveSupport::Concern

    def send_tpi_user_file(mq_assessments:, cp_assessments:, filename:)
      timestamp = Time.now.strftime('%d%m%Y')
      mq_assessments_by_methodology = mq_assessments.group_by(&:methodology_version)
      cp_benchmarks = CP::Benchmark
        .joins(:sector)
        .order('tpi_sectors.name ASC, release_date DESC')
        .includes(sector: [:cp_units])

      mq_assessments_files = mq_assessments_by_methodology.map do |methodology, assessments|
        {
          "MQ_Assessments_Methodology_#{methodology}_#{timestamp}.csv" => CSVExport::User::MQAssessments
            .new(assessments).call
        }
      end.reduce(&:merge)

      timestamp = Time.now.strftime('%d%m%Y')

      latest_cp_assessments_csv = CSVExport::User::CompanyLatestAssessments.new(mq_assessments, cp_assessments).call
      cp_assessments_csv = CSVExport::User::CPAssessments.new(cp_assessments).call
      cp_assessments_regional_csv = CSVExport::User::CPAssessmentsRegional.new(cp_assessments).call
      sector_benchmarks_csv = CSVExport::User::CPBenchmarks.new(cp_benchmarks).call
      data_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'Data_Guide_NH.xlsx'))

      render zip: (mq_assessments_files || {}).merge(
        'Company_Latest_Assessments.csv' => latest_cp_assessments_csv,
        "CP_Assessments_#{timestamp}.csv" => cp_assessments_csv,
        "CP_Assessments_Regional_#{timestamp}.csv" => cp_assessments_regional_csv,
        "Sector_Benchmarks_#{timestamp}.csv" => sector_benchmarks_csv,
        'Data_Guide_NH.xlsx' => data_guide
      ).compact, filename: "#{filename} - #{timestamp}"
    end
  end
end
