class ContentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if !value.attached? || content_types.include?(value.content_type)

    record.errors.add(attribute, 'has wrong content type', options)
  end

  private

  def content_types
    options.fetch(:in)
  end
end
