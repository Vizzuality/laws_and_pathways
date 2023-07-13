class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    return if url_valid?(value)

    record.errors.add(attribute, options[:message] || 'must be a valid URL')
  end

  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
  end
end
