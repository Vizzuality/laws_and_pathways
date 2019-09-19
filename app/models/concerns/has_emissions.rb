module HasEmissions
  extend ActiveSupport::Concern

  def emissions_all_years
    emissions.keys
  end

  def average_emission
    none_empty_values = emissions.values.compact
    return 0 if none_empty_values.empty?

    none_empty_values.map(&:to_f).reduce(:+) / none_empty_values.length
  end

  def emissions=(value)
    if value.is_a?(String)
      write_attribute(:emissions, JSON.parse(value))
    else
      super
    end
  end
end
