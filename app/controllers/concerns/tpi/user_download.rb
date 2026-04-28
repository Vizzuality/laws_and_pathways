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

      chemicals_benchmarks_csv = CSVExport::User::ChemicalsCPBenchmarks.new(cp_benchmarks).call

      files = (mq_assessments_files || {}).merge(
        "CP_Assessments_#{timestamp}.csv" => cp_assessments_csv,
        "CP_Assessments_Regional_#{timestamp}.csv" => cp_assessments_regional_csv,
        "Sector_Benchmarks_#{timestamp}.csv" => sector_benchmarks_csv,
        'User guide TPI files.xlsx' => user_guide
      )
      files["Chemicals_Benchmarks_#{timestamp}.csv"] = chemicals_benchmarks_csv if chemicals_benchmarks_csv
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

      chemicals_benchmarks_csv = CSVExport::User::ChemicalsCPBenchmarks.new(cp_benchmarks).call

      files = {
        'Latest_CP_Assessments.csv' => latest_cp_assessments_csv,
        "CP_Assessments_#{timestamp}.csv" => cp_assessments_csv,
        "CP_Assessments_Regional_#{timestamp}.csv" => cp_assessments_regional_csv,
        "Sector_Benchmarks_#{timestamp}.csv" => sector_benchmarks_csv,
        'User guide - TPI Carbon Performance.xlsx' => user_guide
      }
      files["Chemicals_Benchmarks_#{timestamp}.csv"] = chemicals_benchmarks_csv if chemicals_benchmarks_csv
      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end

    def send_tpi_mq_file(mq_assessments:, filename:, scenario: nil)
      timestamp = Time.now.strftime('%d%m%Y')
      suffix = scenario == 'exempted_10k' ? '_10K' : ''

      methodology_versions = mq_assessments.reorder(nil).distinct.pluck(:methodology_version)
        .sort_by { |v| Gem::Version.new(v) }
      download_includes = {company: [:geography, {sector: :industries}]}

      beta_versions = MQ::Assessment::BETA_METHODOLOGIES.keys
      latest_non_beta = methodology_versions.reject { |v| beta_versions.include?(v) }.last

      mq_assessments_files = {}
      latest_version_assessments = []

      methodology_versions.each do |methodology|
        version_assessments = mq_assessments
          .where(methodology_version: methodology)
          .includes(download_includes)
          .to_a

        preload_mq_assessments_for_status(version_assessments)

        version_suffix = methodology.to_f >= 5 ? suffix : ''
        mq_assessments_files["MQ_Assessments_v#{methodology}#{version_suffix}_#{timestamp}.csv"] =
          CSVExport::User::MQAssessments.new(version_assessments).call

        latest_version_assessments = version_assessments if methodology == latest_non_beta
      end

      latest_mq_assessments_csv = CSVExport::User::LatestMQAssessments.new(latest_version_assessments).call

      user_guide = File.binread(Rails.root.join('public', 'tpi', 'export_support', 'User guide - TPI Management Quality.xlsx'))

      files = {
        "Latest_MQ_Assessments#{suffix}.csv" => latest_mq_assessments_csv
      }.merge(mq_assessments_files).merge(
        'User guide - TPI Management Quality.xlsx' => user_guide
      )

      render zip: files.compact, filename: "#{filename} - #{timestamp}"
    end

    private

    # Pre-populates the company.mq_assessments association with lightweight records
    # (excluding the large `questions` JSONB) so that assessment.status can compute
    # the previous assessment without triggering N+1 queries or loading heavy data.
    def preload_mq_assessments_for_status(assessments)
      company_ids = assessments.map(&:company_id).uniq
      return if company_ids.empty?

      lightweight_assessments = MQ::Assessment
        .where(company_id: company_ids)
        .select(:id, :company_id, :publication_date, :methodology_version, :assessment_date, :level, :discarded_at)
        .to_a
        .group_by(&:company_id)

      assessments.each do |assessment|
        company = assessment.company
        next if company.association(:mq_assessments).loaded?

        company.association(:mq_assessments).target = lightweight_assessments[company.id] || []
      end
    end
  end
end
