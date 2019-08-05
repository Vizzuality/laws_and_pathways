# == Schema Information
#
# Table name: targets
#
#  id               :bigint           not null, primary key
#  location_id      :bigint
#  sector_id        :bigint
#  target_scope_id  :bigint
#  ghg_target       :boolean          default(FALSE), not null
#  single_year      :boolean          default(FALSE), not null
#  description      :text
#  year             :integer
#  base_year_period :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Target < ApplicationRecord
  TYPES = %w[
    base_year_target
    baseline_scenario_target
    fixed_level_target
    intensity_target
    intensity_target_and_trajectory_target
    no_document_submitted
    trajectory_target
  ].freeze
  VISIBILITY = %w[draft pending published archived].freeze

  enum target_type: array_to_enum_hash(TYPES)
  enum visibility_status: array_to_enum_hash(VISIBILITY)

  belongs_to :location
  belongs_to :sector
  belongs_to :target_scope
  has_and_belongs_to_many :legislations

  validates :ghg_target, inclusion: {in: [true, false]}
  validates :single_year, inclusion: {in: [true, false]}
  validates_presence_of :visibility_status

  def to_s
    "Target #{id}"
  end
end
