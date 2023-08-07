module Queries
  module TPI
    class LatestCPAssessmentsQuery
      attr_accessor :category, :cp_assessmentable

      def initialize(category:, cp_assessmentable: nil)
        @category = category.to_s
        @cp_assessmentable = cp_assessmentable
      end

      def call
        query = initial_query
        query = query.where(cp_assessmentable_id: cp_assessmentable.id) if cp_assessmentable.present?
        query.sort_by { |a| [a.cp_assessmentable.try(:name), a.sector.name] }.group_by { |a| [a.cp_assessmentable, a.sector] }
      end

      private

      def initial_query
        CP::Assessment.includes(:cp_assessmentable, :sector, :cp_matrices).joins(
          'LEFT JOIN cp_assessments cp2 ON cp2.cp_assessmentable_id = cp_assessments.cp_assessmentable_id ' \
          'AND cp2.cp_assessmentable_type = cp_assessments.cp_assessmentable_type ' \
          'AND cp2.sector_id = cp_assessments.sector_id ' \
          "AND cp2.publication_date <= '#{Date.current.strftime('%F')}'" \
          'AND cp2.assessment_date > cp_assessments.assessment_date'
        ).where('cp2.cp_assessmentable_id IS NULL').where(cp_assessmentable_type: category).currently_published
      end
    end
  end
end
