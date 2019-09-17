# == Schema Information
#
# Table name: sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cp_unit    :text
#

class Sector < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged, routes: :default

  has_many :companies
  has_many :cp_benchmarks, class_name: 'CP::Benchmark'

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
end
