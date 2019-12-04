module TPI
  module UserDownload
    extend ActiveSupport::Concern

    def send_tpi_user_file(mq_assessments:, cp_assessments:, filename:)
      mq_assessments_by_methodology = mq_assessments.group_by(&:methodology_version)
      cp_benchmarks = CP::Benchmark.includes(:sector)

      mq_assessments_files = mq_assessments_by_methodology.map do |methodology, assessments|
        {
          "MQ_Assessments_Methodology_#{methodology}.csv" => CSVExport::User::MQAssessments.new(assessments).call
        }
      end.reduce(&:merge)

      render zip: mq_assessments_files.merge(
        'CP_Assessments.csv' => CSVExport::User::CPAssessments.new(cp_assessments).call,
        'Sector_Benchmarks.csv' => CSVExport::User::CPBenchmarks.new(cp_benchmarks).call
      ), filename: filename
    end
  end
end
