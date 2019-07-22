# == Schema Information
#
# Table name: legislations
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  law_id      :integer
#  framework   :string
#  slug        :string           not null
#  location_id :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Legislation < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  FRAMEWORKS = %w[mitigation adaptation mitigation_and_adaptation no].freeze
  enum framework: array_to_enum_hash(FRAMEWORKS)

  belongs_to :location

  validates_presence_of :title, :framework, :slug
  validates_uniqueness_of :slug
end
