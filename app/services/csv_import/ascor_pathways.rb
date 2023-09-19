module CSVImport
  class ASCORPathways < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        pathway = prepare_pathway(row)

        pathway.country = countries[row[:country]].first if row.header?(:country)
        pathway.emissions_metric = row[:emissions_metric] if row.header?(:emissions_metric)
        pathway.emissions_boundary = row[:emissions_boundary] if row.header?(:emissions_boundary)
        pathway.land_use = row[:land_use] if row.header?(:land_use)
        pathway.units = row[:units] if row.header?(:units)
        pathway.assessment_date = assessment_date(row) if row.header?(:assessment_date)
        pathway.publication_date = publication_date(row) if row.header?(:publication_date)
        pathway.last_reported_year = row[:last_reported_year] if row.header?(:last_reported_year)
        pathway.emissions = parse_emissions(row) if emission_headers?(row)
        pathway.trend_1_year = row[:'1year_trend'] if row.header?(:'1year_trend')
        pathway.trend_3_year = row[:'3year_trend'] if row.header?(:'3year_trend')
        pathway.trend_5_year = row[:'5year_trend'] if row.header?(:'5year_trend')

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
          land_use: row[:land_use],
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
