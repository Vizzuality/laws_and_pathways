class RenameDisableBubblesAtChartToIsPlaceholder < ActiveRecord::Migration[6.1]
  def change
    rename_column :bank_assessment_indicators, :disable_bubbles_at_chart, :is_placeholder
  end
end
