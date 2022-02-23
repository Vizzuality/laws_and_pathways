class ContentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if !value.attached? || content_types.include?(value.content_type)

    msg = "has wrong content type, found: #{value.content_type}, was expecting: "\
          "#{content_types.join(' or ')}"
    record.errors.add(attribute, msg, options)
  end

  private

  def content_types
    options.fetch(:in)
  end
end
