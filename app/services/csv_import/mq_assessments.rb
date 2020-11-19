module CSVImport
  class MQAssessments < BaseImporter
    include UploaderHelpers

    QUESTION_PATTERN = /Q\d+L(\d+)\|(.+)/.freeze

    def import
      import_each_csv_row(csv) do |row|
        assessment = prepare_assessment(row)
        assessment.assign_attributes(assessment_attributes(row))

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

    def prepare_assessment(row)
      find_record_by(:id, row) ||
        MQ::Assessment.find_or_initialize_by(
          company: find_company!(row),
          assessment_date: assessment_date(row)
        )
    end

    def find_company!(row)
      return unless row[:company_id].present?

      company = Company.find(row[:company_id])
      if company.name.strip.downcase != row[:company].strip.downcase
        puts "!!WARNING!! CHECK YOUR FILE ID DOESN'T MATCH COMPANY NAME!! #{row[:company_id]} #{row[:company]}"
      end
      company
    end

    def assessment_attributes(row)
      {
        assessment_date: assessment_date(row),
        publication_date: publication_date(row),
        level: row[:level],
        notes: row[:notes],
        questions: get_questions(row),
        methodology_version: row[:methodology_version]
      }
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse!(row[:assessment_date], ['%Y-%m-%d', '%d/%m/%Y'])
    end

    def publication_date(row)
      CSVImport::DateUtils.safe_parse!(row[:publication_date], ['%Y-%m'])
    end

    def get_questions(row)
      question_headers = row.headers.map(&:to_s)
        .select { |h| h.strip.start_with?('Q') }

      question_headers.map do |q_header|
        answer = row[q_header]

        next if answer.nil?

        parse_question(q_header).merge(answer: answer)
      end.compact
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
