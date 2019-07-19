# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  type              :string           not null
#  external_url      :text
#  language          :string
#  last_verified_on  :date
#  documentable_type :string
#  documentable_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Document < ApplicationRecord
  self.inheritance_column = nil

  has_one_attached :file

  TYPES = %w[uploaded external].freeze

  enum type: array_to_enum_hash(TYPES)

  validates :external_url, url: true, presence: true, if: :external?
  validates :file, attached: true, if: :uploaded?

  validates_presence_of :name, :type
end
