class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?

    record.errors[attribute] << (options[:message] || 'must be a valid URL') unless url_valid?(value)
  end

  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
  end
end
