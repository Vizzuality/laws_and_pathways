# == Schema Information
#
# Table name: tpi_sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cp_unit    :text
#

class TPISector < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged, routes: :default

  has_many :companies, foreign_key: 'sector_id'
  has_many :cp_benchmarks, class_name: 'CP::Benchmark', foreign_key: 'sector_id'

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  def latest_released_benchmarks
    cp_benchmarks.group_by(&:release_date).max&.last || []
  end
end
