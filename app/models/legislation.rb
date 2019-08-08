# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
#  slug              :string           not null
#  location_id       :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  date_passed       :date
#  visibility_status :string           default("draft")
#

class Legislation < ApplicationRecord
  include UserTrackable
  include Taggable
  include Publishable
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  tag_with :frameworks
  tag_with :document_types
  tag_with :keywords
  tag_with :natural_hazards

  belongs_to :location
  has_and_belongs_to_many :targets
  has_and_belongs_to_many :litigations

  validates_presence_of :title, :slug, :date_passed
  validates_uniqueness_of :slug
end
