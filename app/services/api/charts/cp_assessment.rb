module Api
  module Charts
    class CPAssessment
      BENCHMARK_FILL_COLORS = ['#86A9F9', '#5587F7', '#2465F5', '#0A4BDC', '#083AAB'].freeze

      attr_reader :assessment

      delegate :company, to: :assessment

      def initialize(assessment)
        @assessment = assessment
      end

      # Returns array of following series:
      # - company emissions
      # - company's sector average emissions
      # - company's sector CP benchmarks (scenarios)
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
          emissions_data_from_company,
          emissions_data_from_sector
        ].flatten
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
      def emissions_data_from_company
        data = if assessment&.emissions&.size == 1
                 data_with_marker_settings
               else
                 assessment&.emissions&.transform_keys(&:to_i)
               end
        {
          name: company.name,
          data: data,
          zoneAxis: 'x',
          zones: [{
            value: assessment.last_reported_year&.to_i
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

      def emissions_data_from_sector
        {
          name: "#{company.sector.name} sector mean",
          data: sector_average_emissions
        }
      end

      def emissions_data_from_sector_benchmarks
        company
          .sector
          .latest_benchmarks_for_date(assessment.publication_date)
          .sort_by(&:average_emission)
          .map.with_index do |benchmark, index|
            {
              type: 'area',
              color: BENCHMARK_FILL_COLORS[index],
              fillColor: BENCHMARK_FILL_COLORS[index],
              name: benchmark.scenario,
              data: benchmark.emissions.transform_keys(&:to_i)
            }
          end.reverse
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

      # @return [Float] average emission from all Companies from single year
      def sector_average_emission_for_year(year)
        company_emissions = sector_all_emissions
          .map { |emissions| emissions[year] }
          .compact

        return nil if company_emissions.empty?

        (company_emissions.sum / company_emissions.count).round(2)
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

      # @return [Array<Hash>] list of { year => value } pairs from all Companies from current TPISector
      def sector_all_emissions
        @sector_all_emissions ||= company.sector
          .companies
          .published
          .includes(:cp_assessments)
          .flat_map do |c|
            c.cp_assessments
              .select { |a| a.publication_date <= assessment.publication_date }
              .max_by(&:publication_date)&.emissions&.transform_keys(&:to_i)
          end
          .compact
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
    end
  end
end
