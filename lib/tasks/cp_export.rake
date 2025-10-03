namespace :cp do
  desc 'Export Bank CP assessments for a given bank and assessment date (ENV: BANK, DATE=YYYY-MM-DD, OUT=path)'
  task export_bank_assessments_for_bank: :environment do
    bank_name = ENV.fetch('BANK', nil)
    date_str = ENV.fetch('DATE', nil)
    out = ENV['OUT'] || 'bank_cp_assessments_export.csv'

    abort 'Please provide BANK="Bank Name"' unless bank_name.present?
    abort 'Please provide DATE=YYYY-MM-DD' unless date_str.present?

    date = Date.parse(date_str)
    bank = Bank.find_by!(name: bank_name)

    records = CP::Assessment
      .where(cp_assessmentable: bank)
      .where(assessment_date: date)
      .includes(:sector, :subsector, :cp_matrices)

    headers = [
      'Id', 'Bank Id', 'Bank', 'Sector', 'Subsector', 'Assessment date', 'Publication date',
      'Region', 'Assumptions', 'Years with targets', 'Last reported year'
    ]
    portfolio_year_headers = %w[2025 2030 2035 2050].flat_map do |year|
      CP::Portfolio::NAMES.map { |portfolio| "#{portfolio} #{year}" }
    end

    CSV.open(out, 'w') do |csv|
      csv << (headers + portfolio_year_headers)
      records.each do |a|
        row = [
          a.id,
          a.cp_assessmentable_id,
          bank.name,
          a.sector&.name,
          a.subsector&.name,
          a.assessment_date,
          a.publication_date&.strftime('%Y-%m'),
          a.region,
          a.assumptions,
          Array(a.years_with_targets).join(';'),
          a.last_reported_year
        ]

        matrix_map = a.cp_matrices.index_by(&:portfolio)
        %w[2025 2030 2035 2050].each do |yr|
          CP::Portfolio::NAMES.each do |portfolio|
            row << matrix_map[portfolio]&.public_send("cp_alignment_#{yr}")
          end
        end

        csv << row
      end
    end

    puts "Exported #{records.size} rows to #{out}"
  end
end
