class AddDisableBubblesAtGraphToBankAssessmentIndicator < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_assessment_indicators, :disable_bubbles_at_chart, :boolean, default: false
    BankAssessmentIndicator.area.where(number: ["4"]).update_all disable_bubbles_at_chart: true
  end
end
