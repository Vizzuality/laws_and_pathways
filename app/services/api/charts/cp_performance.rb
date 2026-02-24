module Api
  module Charts
    class CPPerformance
      COLOR_DESCRIPTIONS = {
        '#00C170' => <<~HTML,
          <b>1.5 Degrees</b> in Airlines, Aluminium, Autos, Cement, Diversified Mining, Electricity Utilities, Food Producers, Oil & Gas, Shipping and Steel<br/>
          <b>Below 2 Degrees</b> in Paper
        HTML
        '#FFDD49' => <<~HTML,
          <b>Below 2 Degrees</b> in Airlines, Aluminium, Autos, Cement, Diversified Mining, Electricity Utilities, Food Producers, Oil & Gas, Shipping and Steel<br/>
          <b>2 Degrees</b> in Paper
        HTML
        '#FF9600' => <<~HTML,
          <b>National Pledges</b> in Aluminium, Autos, Cement, Diversified Mining, Electricity Utilities, Oil & Gas and Steel<br/>
          <b>International Pledges</b> in Airlines and Shipping<br/>
          <b>2 Degrees</b> in Food Producers<br/>
          <b>Paris Pledges</b> in Paper
        HTML
        '#ED3D4A' => 'Not Aligned',
        '#595B5D' => 'No or unsuitable disclosure'
      }.freeze

      ALIGNMENT_KEYS = [:cp_alignment_2050, :cp_alignment_2035, :cp_alignment_2028_2030].freeze

      # Sectors excluded from the "All sectors" chart per TPI Centre requirements.
      EXCLUDED_SECTORS = ['Construction and Materials', 'Oil Refining and Marketing'].freeze

      # Calculate companies stats grouped by CP alignment in multiple series.
      # Sort order is important, series should be ordered by CP alignment order
      # data in series should be ordered by sectors cluster and then sector name
      #
      # @return [Array<Hash>] chart data
      # @example
      #   [
      #     {
      #       name: 'Below 2',
      #       data: [ ['Coal Mining', 52], ['Steel', 73] ]
      #     },
      #     {
      #       name: 'Paris Pledges',
      #       data: [ ['Coal Mining', 65], ['Steel', 26] ]
      #     }
      #   ]
      def cp_performance_all_sectors_data
        company_data = extract_company_data(
          Company.published.active.includes(:latest_cp_assessment, sector: [:cluster]),
          [:cp_alignment_2050],
          excluded_sectors: EXCLUDED_SECTORS
        )
        build_alignment_chart(:cp_alignment_2050, company_data)
      end

      def cp_performance_all_sectors_data_all_years
        # Also extract :cp_alignment_2030 to determine whether the short-term
        # button should read "2030" or fall back to "2028".
        extract_keys = ALIGNMENT_KEYS + [:cp_alignment_2030]
        company_data = extract_company_data(
          Company.published.active.includes(:latest_cp_assessment, sector: [:cluster]),
          extract_keys,
          excluded_sectors: EXCLUDED_SECTORS
        )

        result = {}
        [:cp_alignment_2050, :cp_alignment_2035, :cp_alignment_2027].each do |alignment_key|
          result[alignment_key] = cp_performance_all_sectors_by_year(alignment_key, all_companies)
        end

        has_2030 = company_data.any? { |c| c[:alignments][:cp_alignment_2030].present? }
        result[:short_term_year] = has_2030 ? 2030 : 2028

        result
      end

      def cp_performance_for_sectors(sector_ids)
        extract_keys = ALIGNMENT_KEYS + [:cp_alignment_2030]
        company_data = extract_company_data(
          Company.published.active.where(sector_id: sector_ids).includes(:latest_cp_assessment, sector: [:cluster]),
          extract_keys
        )

        result = {}
        [:cp_alignment_2050, :cp_alignment_2035, :cp_alignment_2027].each do |alignment_key|
          result[alignment_key] = cp_performance_all_sectors_by_year(alignment_key, all_companies)
        end

        has_2030 = company_data.any? { |c| c[:alignments][:cp_alignment_2030].present? }
        result[:short_term_year] = has_2030 ? 2030 : 2028

        result
      end

      private

      # Extract only the fields we need from AR objects into lightweight hashes.
      # Uses find_each to process in batches of 500, so only one batch of heavy
      # AR objects is in memory at a time — the rest are GC'd after extraction.
      def extract_company_data(scope, alignment_keys, excluded_sectors: [])
        records = []
        scope.find_each(batch_size: 500) do |company|
          next if excluded_sectors.include?(company.sector.name)

          alignments = {}
          alignment_keys.each { |key| alignments[key] = company.public_send(key) }
          records << {
            sector_name: company.sector.name,
            cluster_name: company.sector.cluster&.name,
            alignments: alignments
          }
        end
        records
      end

      def build_alignment_chart(alignment_key, company_data)
        # Filter to companies with a valid, assessed alignment for this key
        filtered = company_data.select do |c|
          value = c[:alignments][alignment_key]
          value.present? && !CP::Alignment.new(name: value, sector: c[:sector_name]).not_assessed?
        end

        result = cp_alignment_data.map do |color, data|
          {
            name: COLOR_DESCRIPTIONS[color],
            color: color,
            data: (data || []).sort_by do |sn, _v|
              sector = all_sectors.find { |s| s.name == sn }
              [sector.cluster&.name || 'ZZZ', sector.name] # stupid way to sort null last
            end.to_a
          }
        end

        return [] if result.all? { |r| r[:data].empty? }

        result.reject { |r| r[:data].map(&:second).all?(&:zero?) }
      end
    end
  end
end
