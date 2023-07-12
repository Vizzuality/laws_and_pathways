class AttachedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :attached, message: options[:message]) unless value.attached?
  end
end
