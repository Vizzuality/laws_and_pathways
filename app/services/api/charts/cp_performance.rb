module Api
  module Charts
    class CPPerformance
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
        all_companies = Company.published.active.includes(:latest_cp_assessment, sector: [:cluster])
        all_sectors = all_companies.select { |c| c.cp_alignment.present? }.map(&:sector)

        cp_alignment_data = {}

        all_companies.each do |company|
          next if company.cp_alignment.nil?

          cp_alignment = CP::Alignment.new(name: company.cp_alignment)

          cp_alignment_data[cp_alignment.standarized_name] ||= all_sectors.map { |s| {s.name => 0} }.reduce(&:merge)
          cp_alignment_data[cp_alignment.standarized_name]
            .merge!(company.sector.name => 1) { |_k, old_v, new_v| old_v + new_v }
        end

        result = cp_alignment_data.map do |name, data|
          {
            name: name,
            data: data.sort_by do |sn, _v|
              sector = all_sectors.find { |s| s.name == sn }
              [sector.cluster&.name || 'ZZZ', sector.name] # stupid way to sort null last
            end.to_a
          }
        end

        result = result.select { |t| CP::Alignment::ORDER.include?(t[:name].downcase) }

        result.sort_by { |series| CP::Alignment::ORDER.index(series[:name].downcase) }
      end
    end
  end
end
