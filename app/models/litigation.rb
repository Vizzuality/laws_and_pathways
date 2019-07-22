# == Schema Information
#
# Table name: litigations
#
#  id                        :bigint           not null, primary key
#  title                     :string           not null
#  slug                      :string           not null
#  citation_reference_number :string
#  document_type             :string
#  location_id               :bigint
#  jurisdiction_id           :bigint
#  summary                   :text
#  core_objective            :text
#  keywords                  :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Litigation < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  DOCUMENT_TYPES = %w[case investigation inquiry].freeze

  enum document_type: array_to_enum_hash(DOCUMENT_TYPES)

  belongs_to :location
  has_many :litigation_sides

  validates_presence_of :title, :slug, :document_type
end
