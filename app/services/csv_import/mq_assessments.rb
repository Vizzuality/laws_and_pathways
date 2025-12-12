module CSVImport
  class MQAssessments < BaseImporter
    include Helpers

    QUESTION_PATTERN = /Q\d+L(\d+)\|(.+)/.freeze

    def import
      import_each_csv_row(csv) do |row|
        assessment = prepare_assessment(row)

        company = find_company!(row) if row.header?(:company_id)
        assessment.company = company if company.present?

        assessment.methodology_version = row[:methodology_version] if row.header?(:methodology_version)
        assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)
        assessment.publication_date = publication_date(row) if row.header?(:publication_date)
        assessment.level = row[:level].presence if row.header?(:level)
        assessment.fiscal_year = row[:fiscal_year].presence if row.header?(:fiscal_year)
        assessment.assessment_type = row[:assessment_type].presence if row.header?(:assessment_type)
        assessment.downloadable = row[:downloadable].presence if row.header?(:downloadable)
        assessment.notes = row[:notes].presence if row.header?(:notes)
        assessment.questions = get_questions(row) if question_headers?(row)

        was_new_record = assessment.new_record?
        any_changes = assessment.changed?

        assessment.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def header_converters
      lambda do |h|
        return h if h.strip.end_with?('?')

        CSV::HeaderConverters[:symbol].call(h)
      end
    end

    def resource_klass
      MQ::Assessment
    end

    def required_headers
      [:id]
    end

    def prepare_assessment(row)
      existing = find_record_by(:id, row)
      return existing if existing

      company = find_company!(row)
      return MQ::Assessment.new if company.nil?

      MQ::Assessment.find_or_initialize_by(
        company_id: company.id,
        assessment_date: assessment_date(row),
        methodology_version: row[:methodology_version].to_s
      )
    end

    def find_company!(row)
      return unless row[:company_id].present?

      Company.find(row[:company_id])
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse!(row[:assessment_date], ['%Y-%m-%d', '%d/%m/%Y'])
    end

    def publication_date(row)
      CSVImport::DateUtils.safe_parse!(row[:publication_date], ['%Y-%m-%d', '%Y-%m', '%d/%m/%Y'])
    end

    def get_questions(row)
      question_headers(row).map do |q_header|
        answer = row[q_header]

        next if answer.nil?

        parse_question(q_header).merge(answer: answer)
      end.compact
    end

    def question_headers(row)
      row.headers.map(&:to_s).select { |h| h.strip.start_with?('Q') }
    end

    def question_headers?(row)
      question_headers(row).any?
    end

    def parse_question(question)
      return unless question.present?

      matches = question.match(QUESTION_PATTERN)
      level = matches[1]
      text = matches[2]

      {
        question: text,
        level: level
      }
    end
  end
end
