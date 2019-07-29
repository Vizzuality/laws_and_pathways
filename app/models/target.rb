# == Schema Information
#
# Table name: targets
#
#  id               :bigint           not null, primary key
#  location_id      :bigint
#  sector_id        :bigint
#  legislation_id   :bigint
#  ghg_target       :boolean          default(FALSE), not null
#  type             :string           not null
#  description      :text
#  year             :integer
#  base_year_period :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Target < ApplicationRecord
  self.inheritance_column = nil

  TYPES = %w[single_year multi_year other].freeze
  enum type: array_to_enum_hash(TYPES)

  belongs_to :location
  belongs_to :sector
  belongs_to :legislation

  validates :ghg_target, inclusion: {in: [true, false]}
  validates_presence_of :type
end
