# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
#  slug              :string           not null
#  geography_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  date_passed       :date
#  visibility_status :string           default("draft")
#  created_by_id     :bigint
#  updated_by_id     :bigint
#

class Legislation < ApplicationRecord
  include UserTrackable
  include Taggable
  include Publishable
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  EVENT_TYPES = %w[
    drafted
    approved
    came_into_effect
    repealed
  ].freeze

  tag_with :frameworks
  tag_with :document_types
  tag_with :keywords
  tag_with :natural_hazards

  belongs_to :geography
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_and_belongs_to_many :targets
  has_and_belongs_to_many :litigations

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :documents
    accepts_nested_attributes_for :events
  end

  validates_presence_of :title, :slug, :date_passed
  validates_uniqueness_of :slug
end
