class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.array_to_enum_hash(array)
    Hash[array.map { |el| [el, el] }]
  end
end
