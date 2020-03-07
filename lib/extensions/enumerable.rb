# moved from chartkick after chartkick removal
# for multiple series
# use Enumerable so it can be called on arrays
module Enumerable
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def chart_json
    if is_a?(Hash)
      if (key = keys.first) && key.is_a?(Array) && key.size == 2
        group_by { |k, _v| k[0] }.map do |name, data|
          {name: name, data: data.map { |k, v| [k[1], v] }}
        end
      else
        to_a
      end
    elsif is_a?(Array)
      map do |v|
        if v.is_a?(Hash) && v[:data].is_a?(Hash)
          v = v.dup
          v[:data] = v[:data].to_a
        end
        v
      end
    else
      self
    end.to_json
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
