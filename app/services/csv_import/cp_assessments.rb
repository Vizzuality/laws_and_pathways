module CSVImport
  class CPAssessments < BaseImporter
    include Helpers

    def import
      raise NotImplementedError
    end

    private

    def resource_klass
      CP::Assessment
    end

    def required_headers
      [:id]
    end

    def get_years_with_targets(row)
      return unless row[:years_with_targets].present?

      row[:years_with_targets]
        .split(Rails.application.config.csv_options[:entity_sep])
        .map(&:strip)
        .map(&:to_i)
    end

    def assessment_date(row)
      CSVImport::DateUtils.safe_parse!(row[:assessment_date], ['%Y-%m-%d', '%d/%m/%Y']) if row[:assessment_date]
    end

    def publication_date(row)
      CSVImport::DateUtils.safe_parse!(row[:publication_date], ['%Y-%m'])
    end
  end
end
