module ActiveAdminAddonsSelectHelpers
  def array_to_select_options
    selected_values = input_value.is_a?(Array) ? input_value : input_value.to_s.split(',').map(&:strip)
    array = collection.map(&:to_s) + selected_values

    array.sort_by(&:downcase).map do |value|
      option = {id: value, text: value}
      option[:selected] = 'selected' if selected_values.include?(value)
      option
    end.uniq
  end
end
