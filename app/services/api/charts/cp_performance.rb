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
          [:cp_alignment_2050]
        )
        build_alignment_chart(:cp_alignment_2050, company_data)
      end

      def cp_performance_all_sectors_data_all_years
        company_data = extract_company_data(
          Company.published.active.includes(:latest_cp_assessment, sector: [:cluster]),
          ALIGNMENT_KEYS
        )

        result = {}
        ALIGNMENT_KEYS.each do |key|
          result[key] = build_alignment_chart(key, company_data)
        end
        result
      end

      def cp_performance_for_sectors(sector_ids)
        company_data = extract_company_data(
          Company.published.active.where(sector_id: sector_ids).includes(:latest_cp_assessment, sector: [:cluster]),
          ALIGNMENT_KEYS
        )

        result = {}
        ALIGNMENT_KEYS.each do |key|
          result[key] = build_alignment_chart(key, company_data)
        end
        result
      end

      private

      # Extract only the fields we need from AR objects into lightweight hashes.
      # Uses find_each to process in batches of 500, so only one batch of heavy
      # AR objects is in memory at a time — the rest are GC'd after extraction.
      def extract_company_data(scope, alignment_keys)
        records = []
        scope.find_each(batch_size: 500) do |company|
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

        return [] if filtered.empty?

        # Build sector→cluster lookup (O(1) instead of O(N) find)
        sector_cluster = {}
        filtered.each { |c| sector_cluster[c[:sector_name]] ||= c[:cluster_name] }
        all_sector_names = sector_cluster.keys

        # Initialize counts — Hash.new(0) avoids creating N intermediate hashes
        cp_alignment_data = {}
        COLOR_DESCRIPTIONS.each_key { |color| cp_alignment_data[color] = Hash.new(0) }

        # Count companies per color per sector
        filtered.each do |company|
          value = company[:alignments][alignment_key]
          color = CP::Alignment.new(name: value, sector: company[:sector_name]).color
          cp_alignment_data[color] ||= Hash.new(0)
          cp_alignment_data[color][company[:sector_name]] += 1
        end

        # Build result sorted by cluster then sector name
        sorted_sectors = all_sector_names.sort_by { |sn| [sector_cluster[sn] || 'ZZZ', sn] }

        result = cp_alignment_data.map do |color, counts|
          {
            name: COLOR_DESCRIPTIONS[color],
            color: color,
            data: sorted_sectors.map { |sn| [sn, counts[sn]] }
          }
        end

        result.reject { |r| r[:data].map(&:second).all?(&:zero?) }
      end
    end
  end
end
