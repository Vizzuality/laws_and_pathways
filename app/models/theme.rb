# == Schema Information
#
# Table name: themes
#
#  id            :bigint           not null, primary key
#  name          :string
#  theme_type_id :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  discarded_at  :datetime
#

class Theme < ApplicationRecord
  include DiscardableModel

  belongs_to :theme_type
  has_and_belongs_to_many :legislations

  scope :ordered_with_parent, -> { joins(:theme_type).order('theme_types.name ASC, themes.name ASC') }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:theme_type_id], case_sensitive: false

  def self.to_select
    pluck(Arel.sql("CONCAT('[', theme_types.name, '] ', themes.name)"), :id)
  end
end
