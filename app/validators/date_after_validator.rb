class DateAfterValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?

    min_date = options[:with]

    record.errors[attribute] << (options[:message] || "must be after #{min_date}") if value < min_date
  end
end
