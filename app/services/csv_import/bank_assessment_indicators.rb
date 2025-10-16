module CSVImport
  class BankAssessmentIndicators < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        indicator = prepare_indicator(row)

        indicator.indicator_type = row[:type].downcase
        indicator.number = row[:number]
        indicator.text = row[:text]

        was_new_record = indicator.new_record?
        any_changes = indicator.changed?

        indicator.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      BankAssessmentIndicator
    end

    def required_headers
      if override_id
        [:id, :number, :type, :text]
      else
        [:number, :type, :text]
      end
    end

    def prepare_indicator(row)
      return prepare_overridden_resource(row) if override_id

      # When not overriding ID, try to find existing indicator by number and type, or create new one
      BankAssessmentIndicator.where(number: row[:number], indicator_type: row[:type]).first ||
        resource_klass.new
    end
  end
end
