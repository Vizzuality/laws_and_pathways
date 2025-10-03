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
          labels = display_labels_for_selected_assessment_year
          result[year] = labels.each_with_object({}) do |label, section|
            base, sub = parse_label(label)
            sector = all_sectors_by_name[base]
            next unless sector

            if sub.present?
              subsector = sector.subsectors.find { |s| s.name == sub }
              subsector_assessment = cp_assessments[[cp_assessmentable, sector]]&.find { |a| a.subsector_id == subsector&.id }
              subsector_portfolio_values = portfolio_values_from subsector_assessment, year

              section[label] = {
                assumptions: assumption_for(subsector_assessment&.assumptions),
                portfolio_values: subsector_portfolio_values,
                has_emissions: subsector_assessment&.emissions&.present? && has_assessable_targets?(subsector_assessment)
              }
            else
              cp_assessment = cp_assessments[[cp_assessmentable, sector]]&.first
              portfolio_values = portfolio_values_from cp_assessment, year
              section[label] = {
                assumptions: assumption_for(cp_assessment&.assumptions),
                portfolio_values: portfolio_values,
                has_emissions: cp_assessment&.emissions&.present? && has_assessable_targets?(cp_assessment)
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
        {
          sectors: display_labels_for_selected_assessment_year,
          portfolios: CP::Portfolio::NAMES_WITH_CATEGORIES
        }
      end

      def has_assessable_targets?(assessment)
        return false unless assessment.present?
        return false unless assessment.years_with_targets.present? && assessment.years_with_targets.any?

        # Check if any cp_matrices contain "not assessable"
        assessment.cp_matrices.none? do |matrix|
          [
            matrix.cp_alignment_2025,
            matrix.cp_alignment_2027,
            matrix.cp_alignment_2030,
            matrix.cp_alignment_2035,
            matrix.cp_alignment_2050
          ].compact.any? { |alignment| alignment&.downcase&.include?('not assessable') }
        end
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
                              # Default to newest assessment date (same as ERB template)
                              newest_date = CP::Assessment
                                .where(cp_assessmentable: cp_assessmentable)
                                .currently_published
                                .order(assessment_date: :desc)
                                .pluck(:assessment_date)
                                .uniq
                                .first

                              if newest_date.present?
                                records = CP::Assessment
                                  .includes(:cp_assessmentable, :sector, :subsector, :cp_matrices)
                                  .where(cp_assessmentable: cp_assessmentable)
                                  .where(assessment_date: newest_date)
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
        @sectors ||= CP::DisplayOverrides.filter_sectors(
          TPISector.for_category(cp_assessmentable_type).order(:name)
        )
      end

      def all_sectors_by_name
        @all_sectors_by_name ||= TPISector.for_category(cp_assessmentable_type).index_by(&:name)
      end

      def selected_assessment_year
        date = parse_date(selected_assessment_date) || cp_assessments.values.flatten.map(&:assessment_date).compact.max
        date&.year
      end

      def display_labels_for_selected_assessment_year
        year = selected_assessment_year
        if year.nil? || year >= 2025
          SECTORS_FROM_2025
        else
          SECTORS_UP_TO_2024
        end
      end

      def parse_label(label)
        parts = label.split(' - ', 2)
        [parts[0], parts[1]]
      end

      SECTORS_FROM_2025 = [
        'Airlines',
        'Aluminium',
        'Autos',
        'Cement',
        'Chemicals',
        'Coal Mining - Thermal Coal',
        'Coal Mining - Metallurgical Coal',
        'Diversified Mining',
        'Electric Utilities (Global)',
        'Electric Utilities (Regional)',
        'Food',
        'Oil & Gas',
        'Paper',
        'Real Estate',
        'Shipping',
        'Steel'
      ].freeze

      SECTORS_UP_TO_2024 = [
        'Airlines',
        'Aluminium',
        'Autos',
        'Cement',
        'Chemicals',
        'Coal Mining',
        'Diversified Mining',
        'Electric Utilities (Global)',
        'Electric Utilities (Regional)',
        'Oil & Gas',
        'Real Estate',
        'Shipping',
        'Steel'
      ].freeze

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
