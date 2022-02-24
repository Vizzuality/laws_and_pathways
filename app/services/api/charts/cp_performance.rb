module Api
  module Charts
    class CPPerformance
      COLOR_DESCRIPTIONS = {
        '#00C170' => <<~HTML,
          1.5 Degrees in electricity, oil & gas, diversified mining, shipping, and aviation<br/>
          Below 2 Degrees in paper, aluminium, cement, and steel<br/>
          2 Degrees (High Efficiency) in autos
        HTML
        '#FFDD49' => <<~HTML,
          Below 2 Degrees in electricity, oil & gas, diversified mining, shipping, and aviation<br/>
          2 Degrees in paper, aluminium, cement, and steel<br/>
          2 Degrees (Shift-Improve) in autos
        HTML
        '#FF9600' => <<~HTML,
          National Pledges in electricity, oil & gas, and diversified mining<br/>
          International Pledges in aviation and shipping<br/>
          Paris Pledges in autos, paper, aluminium, cement, and steel
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
          .select { |c| c.cp_alignment.present? }
          .reject { |c| CP::Alignment.new(name: c.cp_alignment, sector: c.sector.name).not_assessed? }

        all_sectors = all_companies.map(&:sector).uniq
        cp_alignment_data = COLOR_DESCRIPTIONS.keys
          .map { |name| {name => all_sectors.map { |s| {s.name => 0} }.reduce(&:merge)} }
          .reduce(&:merge)

        all_companies.each do |company|
          cp_alignment = CP::Alignment.new(name: company.cp_alignment, sector: company.sector.name)
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
