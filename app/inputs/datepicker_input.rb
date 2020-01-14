class DatepickerInput < ActiveAdmin::Inputs::DatepickerInput
  # Called in ActiveAdmin::Inputs::DatepickerInput#input_html_options
  def datepicker_options
    super.tap do |options|
      options[:datepicker_options]['dateFormat'] ||= 'dd/mm/yy'
    end
  end
end
