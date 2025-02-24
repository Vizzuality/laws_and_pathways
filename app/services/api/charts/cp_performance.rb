module Api
  module Charts
    class CPPerformance
      COLOR_DESCRIPTIONS = {
        '#00C170' => <<~HTML,
          <b>1.5 Degrees</b> in Airlines, Aluminium, Autos, Cement, Diversified Mining, Electricity Utilities, Food Producers, Oil & Gas, Shipping and Steel<br/>
          <b>Below 2 Degrees</b> in Paper
        HTML
        '#FFDD49' => <<~HTML,
          <b>Below 2 Degrees</b> in Airlines, Aluminium, Autos, Cement, Diversified Mining, Electricity Utilities, Food Producers, Oil & Gas, Shipping and<br/>
          Steel<br/>
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
        all_companies = Company
          .published
          .active
          .includes(:latest_cp_assessment, sector: [:cluster])
          .select { |c| c.cp_alignment_2050.present? }
          .reject { |c| CP::Alignment.new(name: c.cp_alignment_2050, sector: c.sector.name).not_assessed? }

        all_sectors = all_companies.map(&:sector).uniq
        cp_alignment_data = COLOR_DESCRIPTIONS.keys
          .map { |name| {name => all_sectors.map { |s| {s.name => 0} }.reduce(&:merge)} }
          .reduce(&:merge)

        all_companies.each do |company|
          cp_alignment = CP::Alignment.new(name: company.cp_alignment_2050, sector: company.sector.name)
          alignment_key = cp_alignment.color
          cp_alignment_data[alignment_key] ||= all_sectors.map { |s| {s.name => 0} }.reduce(&:merge)
          cp_alignment_data[alignment_key]
            .merge!(company.sector.name => 1) { |_k, old_v, new_v| old_v + new_v }
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
