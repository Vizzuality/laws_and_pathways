class ArrayInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    Array.wrap(value).each do |v|
      unless Array.wrap(options[:in]).include? v
        message = (options[:message].try(:gsub, '%<value>s', value) || "#{value} is not included in the list")
        record.errors.add(attribute, :array_inclusion, message: message, value: value)
      end
    end
  end
end
