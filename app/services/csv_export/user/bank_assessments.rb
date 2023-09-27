module CSVExport
  module User
    class BankAssessments
      def call
        return if assessments.empty?

        headers = [
          'Bank',
          'Geography',
          'Geography ISO',
          'Sector',
          'Market cap group',
          'ISINs',
          'SEDOL',
          'Assessment Date',
          *results_columns.map(&:column_name),
          'Latest information'
        ]

        # BOM UTF-8
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          assessments.each do |assessment|
            csv << [
              assessment.bank.name,
              assessment.bank.geography.name,
              assessment.bank.geography.iso,
              'Banks',
              assessment.bank.market_cap_group,
              assessment.bank.isin&.tr(',', ';')&.tr(' ', ''),
              assessment.bank.sedol&.tr(',', ';')&.tr(' ', ''),
              assessment.assessment_date,
              results_columns.map do |column|
                next 'N/A' if column.is_placeholder

                all_results[[assessment.id, column.type, column.number]]&.first&.decorate&.value
              end,
              assessment.bank.latest_information&.squish
            ].flatten
          end
        end
      end

      private

      def assessments
        @assessments ||= BankAssessment.includes(bank: :geography).joins(:bank).order(:assessment_date, 'banks.name')
      end

      def all_results
        @all_results ||= BankAssessmentResult
          .includes(:indicator)
          .group_by { |r| [r.bank_assessment_id, r.indicator.indicator_type, r.indicator.number] }
      end

      def results_columns
        @results_columns ||= begin
          indicators = indicator_areas.values.flatten.map { |area| [area, child_indicators[area.number]] }.flatten
          indicators.map do |indicator|
            OpenStruct.new(
              type: indicator.indicator_type,
              number: indicator.number,
              column_name: "#{indicator.indicator_type.humanize} #{indicator.number}",
              is_placeholder: indicator_areas[indicator.number.split('.').first]&.first&.is_placeholder
            )
          end
        end
      end

      def indicator_areas
        @indicator_areas ||= BankAssessmentIndicator
          .where(indicator_type: 'area')
          .order('length(number), number')
          .group_by(&:number)
      end

      def child_indicators
        @child_indicators ||= BankAssessmentIndicator
          .where.not(indicator_type: %w[area sub_area])
          .group_by { |r| r.number.split('.').first }
      end
    end
  end
end
