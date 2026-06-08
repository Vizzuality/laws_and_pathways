module Api
  module Charts
    class ChemicalsSector
      TIMEFRAMES = {
        'Short-term' => %i[cp_alignment_2030 cp_alignment_2028 cp_alignment_2027],
        'Medium-term' => %i[cp_alignment_2035],
        'Long-term' => %i[cp_alignment_2050]
      }.freeze

      def initialize(sector)
        @sector = sector
      end

      # Returns alignment counts grouped by scenario and timeframe.
      #
      # @return [Hash] { timeframe_label => { scenario_name => count } }
      # @example
      #   {
      #     "Short-term" => { "1.5 Degrees" => 3, "2 Degrees" => 5, "Not Aligned" => 2 },
      #     "Medium-term" => { ... },
      #     "Long-term" => { ... }
      #   }
      def alignment_data
        assessments = latest_assessments

        TIMEFRAMES.each_with_object({}) do |(label, fields), result|
          counts = Hash.new(0)

          assessments.each do |assessment|
            value = resolve_alignment(assessment, fields)
            next unless value.present?

            formatted = CP::Alignment.format_name(value) || value
            counts[formatted] += 1
          end

          result[label] = counts
        end
      end

      private

      def resolve_alignment(assessment, fields)
        fields.each do |field|
          val = assessment.public_send(field)
          return val if val.present?
        end
        nil
      end

      def latest_assessments
        published_company_ids = @sector.companies.published.pluck(:id)
        return [] if published_company_ids.empty?

        CP::Assessment
          .currently_published
          .companies
          .where(cp_assessmentable_id: published_company_ids)
          .group_by(&:cp_assessmentable_id)
          .map { |_id, group| group.max_by(&:publication_date) }
      end
    end
  end
end
