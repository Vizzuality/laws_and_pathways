module Api
  module Charts
    class CPMatrix
      attr_accessor :cp_assessmentable, :selected_assessment_date

      def initialize(cp_assessmentable, selected_assessment_date = nil)
        @cp_assessmentable = cp_assessmentable
        @selected_assessment_date = selected_assessment_date.presence
      end

      def matrix_data
        {data: collect_data, meta: collect_metadata}
      end

      private

      def collect_data
        return [] unless cp_assessmentable.present?

        # Determine alignment years based on assessment date
        alignment_years = determine_alignment_years
        alignment_years.each_with_object({}) do |year, result|
          result[year] = sectors.each_with_object({}) do |sector, section|
            cp_assessment = cp_assessments[[cp_assessmentable, sector]]&.first

            # Get all subsectors for this sector
            sector_subsectors = sector.subsectors
            if sector_subsectors.any?
              # Create entries for each subsector
              sector_subsectors.each do |subsector|
                # Find the specific CP assessment for this subsector if it exists
                subsector_assessment = cp_assessments[[cp_assessmentable, sector]]&.find { |a| a.subsector_id == subsector.id }
                subsector_portfolio_values = portfolio_values_from subsector_assessment, year

                section["#{sector.name} - #{subsector.name}"] = {
                  assumptions: assumption_for(subsector_assessment&.assumptions),
                  portfolio_values: subsector_portfolio_values,
                  has_emissions: subsector_assessment&.emissions&.present?
                }
              end
            else
              portfolio_values = portfolio_values_from cp_assessment, year
              # No subsectors, use sector name directly
              section[sector.name] = {
                assumptions: assumption_for(cp_assessment&.assumptions),
                portfolio_values: portfolio_values,
                has_emissions: cp_assessment&.emissions&.present?
              }
            end
          end
        end
      end

      def assumption_for(value)
        return nil if value.blank? || value == '0'

        value
      end

      def portfolio_values_from(cp_assessment, year)
        CP::Portfolio::NAMES.each_with_object({}) do |portfolio, row|
          old_portfolio = CP::Portfolio::NAME_MAP[portfolio]
          # keep support for old portfolio names but also support new ones
          value = cp_assessment&.cp_matrices&.detect { |m| m.portfolio == old_portfolio || m.portfolio == portfolio }
          row[portfolio] = value&.public_send "cp_alignment_#{year}"
        end
      end

      def collect_metadata
        sector_names = sectors.flat_map do |sector|
          sector_subsectors = sector.subsectors

          if sector_subsectors.any?
            # Create names for each subsector
            sector_subsectors.map { |subsector| "#{sector.name} - #{subsector.name}" }
          else
            # No subsectors, use sector name directly
            [sector.name]
          end
        end

        {
          sectors: sector_names,
          portfolios: CP::Portfolio::NAMES_WITH_CATEGORIES
        }
      end

      def cp_assessments
        @cp_assessments ||= if selected_assessment_date.present?
                              date = parse_date(selected_assessment_date)
                              records = CP::Assessment
                                .includes(:cp_assessmentable, :sector, :subsector, :cp_matrices)
                                .where(cp_assessmentable: cp_assessmentable)
                                .where(assessment_date: date)
                                .currently_published
                              records
                                .sort_by { |a| [a.cp_assessmentable.try(:name), a.sector.name] }
                                .group_by { |a| [a.cp_assessmentable, a.sector] }
                            else
                              # Default to oldest assessment date
                              oldest_date = CP::Assessment
                                .where(cp_assessmentable: cp_assessmentable)
                                .currently_published
                                .order(:assessment_date)
                                .pluck(:assessment_date)
                                .first

                              if oldest_date.present?
                                records = CP::Assessment
                                  .includes(:cp_assessmentable, :sector, :subsector, :cp_matrices)
                                  .where(cp_assessmentable: cp_assessmentable)
                                  .where(assessment_date: oldest_date)
                                  .currently_published
                                records
                                  .sort_by { |a| [a.cp_assessmentable.try(:name), a.sector.name] }
                                  .group_by { |a| [a.cp_assessmentable, a.sector] }
                              else
                                {}
                              end
                            end
      end

      def sectors
        @sectors ||= TPISector.for_category(cp_assessmentable_type).order(:name)
      end

      def cp_assessmentable_type
        cp_assessmentable.class.to_s
      end

      def parse_date(value)
        return value if value.is_a?(Date)

        Date.parse(value.to_s)
      rescue ArgumentError
        nil
      end

      def latest_per_sector_and_subsector(records)
        grouped = records.group_by { |a| [a.sector_id, a.subsector_id] }
        grouped.values.map { |assessments| assessments.max_by { |a| a.assessment_date || Date.new(0) } }
      end

      def determine_alignment_years
        if selected_assessment_date.present?
          date = parse_date(selected_assessment_date)
          year = date&.year

          if year && year < 2025
            %w[2027 2035 2050]
          else
            %w[2030 2035 2050]
          end
        else
          # Default to 2025+ alignment years
          %w[2030 2035 2050]
        end
      end
    end
  end
end
