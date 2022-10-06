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
        @results_columns ||= assessments
          .first
          .results
          .includes(:indicator)
          .order('bank_assessment_indicators.number')
          .map do |result|
            next nil if result.indicator.sub_area?

            type = result.indicator.indicator_type
            number = result.indicator.number
            OpenStruct.new(
              type: type,
              number: number,
              column_name: "#{type.humanize} #{number}"
            )
          end.compact
      end
    end
  end
end
