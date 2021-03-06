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

      render zip: (mq_assessments_files || {}).merge(
        'Company_Latest_Assessments.csv' => CSVExport::User::CompanyLatestAssessments
          .new(mq_assessments, cp_assessments).call,
        "CP_Assessments_#{timestamp}.csv" => CSVExport::User::CPAssessments.new(cp_assessments).call,
        "Sector_Benchmarks_#{timestamp}.csv" => CSVExport::User::CPBenchmarks.new(cp_benchmarks).call
      ).compact, filename: "#{filename} - #{timestamp}"
    end
  end
end
