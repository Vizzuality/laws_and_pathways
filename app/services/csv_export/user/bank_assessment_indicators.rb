module CSVExport
  module User
    class BankAssessmentIndicators
      def call
        @indicators = BankAssessmentIndicator.order(:id)
        return if @indicators.empty?

        headers = %w[
          Type
          Number
          Text
        ]

        # BOM UTF-8
        CSV.generate("\xEF\xBB\xBF") do |csv|
          csv << headers

          @indicators.each do |indicator|
            csv << [
              indicator.indicator_type.humanize,
              indicator.number,
              indicator.text
            ]
          end
        end
      end
    end
  end
end
