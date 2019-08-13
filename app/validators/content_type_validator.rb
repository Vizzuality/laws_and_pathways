class ContentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if !value.attached? || content_types.select { |c| value.content_type.include?(c) }.any?

    record.errors.add(attribute, 'wrong content type', options)
    value.purge
  end

  private

  def content_types
    options.fetch(:in)
  end
end
