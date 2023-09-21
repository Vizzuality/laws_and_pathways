module CSVImport
  class ASCORPathways < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        pathway = prepare_pathway(row)

        pathway.country = countries[row[:country]].first if row.header?(:country)
        pathway.emissions_metric = row[:emissions_metric] if row.header?(:emissions_metric)
        pathway.emissions_boundary = row[:emissions_boundary] if row.header?(:emissions_boundary)
        pathway.units = row[:units] if row.header?(:units)
        pathway.assessment_date = assessment_date(row) if row.header?(:assessment_date)
        pathway.publication_date = publication_date(row) if row.header?(:publication_date)
        pathway.last_historical_year = row[:last_historical_year] if row.header?(:last_historical_year)
        pathway.trend_1_year = row[:metric_ep1aii_1year] if row.header?(:metric_ep1aii_1year)
        pathway.trend_3_year = row[:metric_ep1aii_3year] if row.header?(:metric_ep1aii_3year)
        pathway.trend_5_year = row[:metric_ep1aii_5year] if row.header?(:metric_ep1aii_5year)
        pathway.trend_source = row[:source_metric_ep1aii] if row.header?(:source_metric_ep1aii)
        pathway.trend_year = row[:year_metric_ep1aii] if row.header?(:year_metric_ep1aii)
        pathway.recent_emission_level = string_to_float(row[:metric_ep1ai]) if row.header?(:metric_ep1ai)
        pathway.recent_emission_source = row[:source_metric_ep1ai] if row.header?(:source_metric_ep1ai)
        pathway.recent_emission_year = row[:year_metric_ep1ai] if row.header?(:year_metric_ep1ai)
        pathway.emissions = parse_emissions(row, thousands_separator: ',') if emission_headers?(row)

        was_new_record = pathway.new_record?
        any_changes = pathway.changed?

        pathway.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      ASCOR::Pathway
    end

    def required_headers
      [:id]
    end

    def prepare_pathway(row)
      find_record_by(:id, row) ||
        ASCOR::Pathway.find_or_initialize_by(
          country: countries[row[:country]].first,
          emissions_metric: row[:emissions_metric],
          emissions_boundary: row[:emissions_boundary],
          assessment_date: assessment_date(row)
        )
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
