module Api
  module Charts
    class CPAssessment
      BENCHMARK_FILL_COLORS = ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'].freeze
      BANK_COMPANY_SECTOR_PAIRS = {
        'Electric Utilities (Global)' => 'Electricity Utilities',
        'Electric Utilities (Regional)' => 'Electricity Utilities'
      }.freeze

      attr_reader :assessment

      delegate :sector, to: :assessment

      def initialize(assessment, view)
        @assessment = assessment
        @category = assessment&.cp_assessmentable_type
        @view = view
      end

      # Returns array of following series:
      # - assessment emissions
      # - assessment's sector average emissions
      # - assessment's sector CP benchmarks (scenarios)
      #
      # @return [Array]
      # @example
      #   [
      #     { name: 'Air China',                   data: { 2014 => 111.0, 2015 => 112.0 } },
      #
      #     { name: 'Airlines sector mean',        data: { ... } },
      #
      #     { name: '2 Degrees (Shift-Improve)',   data: { ... } },
      #     { name: '2 Degrees (High Efficiency)', data: { ... } },
      #   ]
      #
      def emissions_data
        return [] unless assessment.present?

        [
          emissions_data_from_sector_benchmarks,
          emissions_data_from_assessment,
          emissions_data_from_sector,
          years_with_targets
        ].compact.flatten
      end

      private

      # Data format for emissions
      #
      # If there are more than one data point:
      # [[x,y], [x1,y1], ...]
      #
      # If there's only one point we change the format so that we can control
      # the marker symbol, to ensure that it's visible on the chart
      # [
      #   {
      #     y: yvalue,
      #     x: xvalue,
      #     marker: {
      #       symbol: 'circle',
      #       enabled: true,
      #       radius: 3
      #     }
      #   }
      # ]
      def emissions_data_from_assessment
        data = if assessment&.emissions&.size == 1
                 data_with_marker_settings
               else
                 assessment&.emissions&.transform_keys(&:to_i)
               end
        {
          name: assessment.cp_assessmentable.name,
          data: data,
          zoneAxis: 'x',
          zones: [{
            value: (assessment.last_reported_year&.to_i || 0) + 0.1
          }, {
            dashStyle: 'dot'
          }]
        }
      end

      def data_with_marker_settings
        [{
          y: assessment&.emissions&.first&.second,
          x: assessment&.emissions&.first&.first&.to_i,
          marker: {
            symbol: 'circle',
            enabled: true,
            radius: 3
          }
        }]
      end

      def years_with_targets
        return unless assessment&.years_with_targets&.any?
        return unless assessment&.emissions&.any?

        emissions = assessment.emissions.transform_keys(&:to_i)
        data = assessment.years_with_targets
          .map { |year| [year, emissions[year]] }
          .select { |year_emission| year_emission[1].present? }

        {
          name: 'Target Years',
          type: 'line',
          lineWidth: 0,
          marker: {
            symbol: 'circle',
            enabled: true,
            radius: 5,
            fillColor: '#00C170'
          },
          states: {
            hover: {
              lineWidth: 0
            }
          },
          data: data
        }
      end

      def emissions_data_from_sector
        name = if @category == 'Bank'
                 'Sector mean'
               elsif regional_view?
                 "#{region} #{sector.name} sector mean"
               else
                 "#{sector.name} sector mean"
               end
        {
          name: name,
          data: sector_average_emissions
        }
      end

      def emissions_data_from_sector_benchmarks
        sector_benchmarks_for_chart
          .sort_by(&:average_emission)
          .map.with_index do |benchmark, index|
            {
              type: 'area',
              color: BENCHMARK_FILL_COLORS[index],
              fillColor: BENCHMARK_FILL_COLORS[index],
              name: benchmark.scenario,
              sector: sector.name,
              subsector: benchmark.subsector,
              data: benchmark.emissions.transform_keys(&:to_i)
            }
          end.reverse
      end

      def sector_benchmarks_for_chart
        selected_region = regional_view? ? assessment.region : nil
        initial = sector
          .latest_benchmarks_for_date(
            assessment.publication_date,
            category: @category,
            region: selected_region,
            subsector: assessment.subsector_name
          )
        return initial if initial.present?

        sector
          .latest_benchmarks_for_date(
            assessment.publication_date,
            category: @category,
            region: selected_region,
            subsector: nil
          )
      end

      # Returns average emissions history for given TPISector.
      # For each year, average value is calculated from all available
      # companies emissions, up to last reported year.
      #
      # @example {2014 => 111.0, 2015 => 112.0 }
      #
      def sector_average_emissions
        years_with_reported_emissions
          .map { |year| [year.to_i, sector_average_emission_for_year(year)] }
          .to_h
      end

      # @return [Float] average emission from all entities from single year
      def sector_average_emission_for_year(year)
        emissions_for_year = sector_all_emissions
          .map { |emissions| emissions[year] }
          .compact
        return nil if emissions_for_year.empty?

        (emissions_for_year.sum / emissions_for_year.count).round(2)
      end

      # @return [Array] of years for which emissions was reported
      def years_with_reported_emissions
        return [] if sector_all_emission_years.empty?

        (sector_all_emission_years.min..assessment_last_reported_year).map.to_a
      end

      # @return [Array] unique array of years as numbers
      def sector_all_emission_years
        sector_all_emissions
          .flat_map(&:keys)
          .map(&:to_i)
          .uniq
      end

      # @return [Array<Hash>] list of { year => value } pairs from all Companies or Banks from current TPISector
      def sector_all_emissions
        @sector_all_emissions = sector_all_emissions_for_company
        @sector_all_emissions = @sector_all_emissions.where(region: region) if regional_view? && @category != 'Bank'
        @sector_all_emissions.group_by(&:cp_assessmentable_id).flat_map do |_id, cp_assessments|
          cp_assessments.max_by(&:publication_date)&.emissions&.transform_keys(&:to_i)
        end
      end

      def sector_all_emissions_for_company
        CP::Assessment.joins(:sector).where(
          tpi_sectors: {name: [sector.name, BANK_COMPANY_SECTOR_PAIRS[sector.name]]},
          publication_date: [..assessment.publication_date],
          cp_assessmentable_type: Company.to_s,
          cp_assessmentable_id: Company.published.select(:id)
        )
      end

      # @return [Integer]
      def assessment_last_reported_year
        # fixing bug when last_reported year is nil we will guess it
        # the validation will be added to always have last reported year if emissions present
        assessment.last_reported_year ||
          [
            assessment&.emissions&.transform_keys(&:to_i)&.keys&.max || current_year,
            current_year
          ].min
      end

      # @return [Integer]
      def current_year
        Time.new.year
      end

      def region
        @assessment.region
      end

      def regional_view?
        @view == 'regional'
      end
    end
  end
end
