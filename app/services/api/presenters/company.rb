module Api
  module Presenters
    class Company
      def initialize(company, view)
        @company = company
        @view = view
      end

      def summary
        OpenStruct.new(
          name: @company.name,
          country: @company.geography.name,
          sector: @company.sector.name,
          market_cap: @company.market_cap_group.titlecase,
          isin: @company.isin,
          sedol: @company.sedol,
          ca100: @company.ca100 ? 'Yes' : 'No'
        )
      end

      def graph_cp_assessments
        return graph_cp_assessments_by_region if regional_view?

        unless subsector_latest_cp_assessments?
          return [] unless @company.latest_cp_assessment.present?

          return [@company.latest_cp_assessment]
        end

        latest_cp_assessments
      end

      def cp_assessments
        assessments = @company.cp_assessments.currently_published
        assessments = assessments.where.not(region: nil) if regional_view?
        assessments.order(assessment_date: :desc)
      end

      def mq_assessments
        query = @company.mq_assessments.currently_published.order(publication_date: :desc, assessment_date: :desc)
        query = query.without_beta_methodologies unless @company.show_beta_mq_assessments
        query
      end

      def cp_alignment_2025
        return unless @company.cp_alignment_2025.present?

        CP::Alignment.new(name: @company.cp_alignment_2025, sector: @company.sector.name)
      end

      def cp_alignment_2027
        return unless @company.cp_alignment_2027.present?

        CP::Alignment.new(name: @company.cp_alignment_2027, sector: @company.sector.name)
      end

      def cp_alignment_2028
        return unless @company.cp_alignment_2028.present?

        CP::Alignment.new(name: @company.cp_alignment_2028, sector: @company.sector.name)
      end

      def cp_alignment_2035
        return unless @company.cp_alignment_2035.present?

        CP::Alignment.new(name: @company.cp_alignment_2035, sector: @company.sector.name)
      end

      def cp_alignment_2050
        return unless @company.cp_alignment_2050.present?

        CP::Alignment.new(name: @company.cp_alignment_2050, sector: @company.sector.name)
      end

      def cp_alignment_region
        @company.cp_alignment_region
      end

      def cp_regional_alignment_2025
        return unless @company.cp_regional_alignment_2025.present?

        CP::Alignment.new(name: @company.cp_regional_alignment_2025, sector: @company.sector.name)
      end

      def cp_regional_alignment_2027
        return unless @company.cp_regional_alignment_2027.present?

        CP::Alignment.new(name: @company.cp_regional_alignment_2027, sector: @company.sector.name)
      end

      def cp_regional_alignment_2028
        return unless @company.cp_regional_alignment_2028.present?

        CP::Alignment.new(name: @company.cp_regional_alignment_2028, sector: @company.sector.name)
      end

      def cp_regional_alignment_2035
        return unless @company.cp_regional_alignment_2035.present?

        CP::Alignment.new(name: @company.cp_regional_alignment_2035, sector: @company.sector.name)
      end

      def cp_regional_alignment_2050
        return unless @company.cp_regional_alignment_2050.present?

        CP::Alignment.new(name: @company.cp_regional_alignment_2050, sector: @company.sector.name)
      end

      def regional_view?
        @view == 'regional'
      end

      private

      def subsector_latest_cp_assessments?
        @company.latest_cp_assessments_by_subsector.present?
      end

      def subsector_latest_regional_cp_assessments?
        @company.latest_regional_cp_assessments_by_subsector.present?
      end

      def graph_cp_assessments_by_region
        unless subsector_latest_regional_cp_assessments?
          return [] unless @company.latest_cp_assessment_regional.present?

          return [@company.latest_cp_assessment_regional]
        end

        latest_cp_assessments
      end

      def latest_cp_assessments
        return @company.latest_regional_cp_assessments_by_subsector if regional_view?

        @company.latest_cp_assessments_by_subsector
      end
    end
  end
end
