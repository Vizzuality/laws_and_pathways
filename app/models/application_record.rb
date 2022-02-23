class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.array_to_enum_hash(array)
    array.map { |el| [el, el] }.to_h
  end
end
