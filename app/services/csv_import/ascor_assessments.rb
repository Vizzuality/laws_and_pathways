module CSVImport
  class ASCORAssessments < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        assessment = prepare_assessment(row)

        assessment.country = countries[row[:country]].first if row.header?(:country)
        assessment.assessment_date = assessment_date(row) if row.header?(:assessment_date)
        assessment.publication_date = publication_date(row) if row.header?(:publication_date)
        assessment.notes = row[:research_notes] if row.header?(:research_notes)

        was_new_record = assessment.new_record?

        assessment.save!
        save_assessment_results! assessment, row

        update_import_results(was_new_record, !was_new_record)
      end
    end

    private

    def header_converters
      converter = lambda { |header| header.squish.tr(' ', '_').downcase.underscore.to_sym }
      [converter]
    end

    def resource_klass
      ASCOR::Assessment
    end

    def required_headers
      [:id]
    end

    def prepare_assessment(row)
      find_record_by(:id, row) ||
        ASCOR::Assessment.find_or_initialize_by(
          country: countries[row[:country]].first,
          assessment_date: assessment_date(row)
        )
    end

    def save_assessment_results!(assessment, row)
      ASCOR::AssessmentIndicator.all.each do |indicator|
        value_key = "#{indicator.indicator_type}_#{indicator.code.underscore}".to_sym
        result = ASCOR::AssessmentResult.find_or_initialize_by(assessment: assessment, indicator: indicator)
        result.answer = row[value_key] if row.header?(value_key)
        [:source, :year].each do |attr|
          result.public_send("#{attr}=", row["#{attr}_#{value_key}".to_sym]) if row.header?("#{attr}_#{value_key}".to_sym)
        end
        result.save!
      end
    end

    def countries
      @countries ||= ASCOR::Country.all.group_by(&:name)
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse!(row[:assessment_date], ['%Y-%m-%d', '%m/%d/%y']) if row[:assessment_date]
    end

    def publication_date(row)
      CSVImport::DateUtils.safe_parse!(row[:publication_date], ['%Y-%m'])
    end
  end
end
