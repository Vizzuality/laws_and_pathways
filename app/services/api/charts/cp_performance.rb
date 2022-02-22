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
        # TODO: refactor because of ASAP changes
        all_companies = Company
          .published
          .active
          .includes(:latest_cp_assessment, sector: [:cluster])
          .select { |c| c.cp_alignment.present? }
        # .select { |c| c.latest_cp_assessment.publication_date >= Date.new(2021, 10, 1) }

        all_sectors = all_companies.map(&:sector).uniq
        cp_alignment_objects = {}
        cp_alignment_data = (CP::Alignment::NAMES - ['Not Assessed'])
          .map { |name| {name => all_sectors.map { |s| {s.name => 0} }.reduce(&:merge)} }
          .reduce(&:merge)

        all_companies.each do |company|
          next if company.cp_alignment.nil?

          cp_alignment = CP::Alignment.new(name: company.cp_alignment, sector: company.sector.name)
          next if cp_alignment.not_assessed?

          alignment_key = if cp_alignment.formatted_name == 'Below 2 Degrees' &&
              %w(steel aluminium paper cement).include?(company.sector.name.downcase)
                            'Below 2 Degrees (Paper/Aluminium/Cement/Steel)'
                          else
                            cp_alignment.formatted_name
                          end
          cp_alignment_objects[alignment_key] = cp_alignment
          cp_alignment_data[alignment_key] ||= all_sectors.map { |s| {s.name => 0} }.reduce(&:merge)
          cp_alignment_data[alignment_key]
            .merge!(company.sector.name => 1) { |_k, old_v, new_v| old_v + new_v }
        end

        result = cp_alignment_data.map do |name, data|
          {
            name: name,
            color: cp_alignment_objects[name]&.color,
            data: (data || []).sort_by do |sn, _v|
              sector = all_sectors.find { |s| s.name == sn }
              [sector.cluster&.name || 'ZZZ', sector.name] # stupid way to sort null last
            end.to_a
          }
        end

        return [] if result.all? { |r| r[:data].empty? }

        result = result.select { |t| CP::Alignment::NAMES.map(&:downcase).include?(t[:name].downcase) }
        result = result.reject { |r| r[:data].map(&:second).all?(&:zero?) }

        result.sort_by { |series| CP::Alignment::NAMES.map(&:downcase).index(series[:name].downcase) }
      end
    end
  end
end
