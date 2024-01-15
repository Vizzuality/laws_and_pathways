class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.array_to_enum_hash(array)
    array.map { |el| [el, el] }.to_h
  end

  def self.ransackable_associations(_auth_object = nil)
    @ransackable_associations ||= reflect_on_all_associations.map { |a| a.name.to_s }
  end

  def self.ransackable_attributes(_auth_object = nil)
    @ransackable_attributes ||= column_names + _ransackers.keys + _ransack_aliases.keys + attribute_aliases.keys
  end
end
