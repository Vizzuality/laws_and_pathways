module CSVImport
  class MQAssessments < BaseImporter
    include UploaderHelpers

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
          assessment_date: parse_date(row[:assessment_date])
        )
    end

    def find_company!(row)
      return unless row[:company].present?

      Company.where('lower(name) = ?', row[:company].downcase).first!
    end

    def assessment_attributes(row)
      {
        assessment_date: parse_date(row[:assessment_date]),
        publication_date: parse_date(row[:publication_date]),
        level: row[:level],
        notes: row[:notes],
        questions: get_questions(row)
      }
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

      matches = question.match(/Q\d+L(\d+)\|(.+)/)
      level = matches[1]
      text = matches[2]

      {
        question: text,
        level: level
      }
    end

    def parse_date(date)
      Import::DateUtils.safe_parse(date, ['%Y-%m', '%Y-%m-%d'])
    end
  end
end
