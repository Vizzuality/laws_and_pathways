# == Schema Information
#
# Table name: industries
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Industry < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:slugged, :history], routes: :default

  has_many :tpi_sectors, foreign_key: :industry_id, inverse_of: :industry

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end

