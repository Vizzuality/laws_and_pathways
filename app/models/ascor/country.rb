class ASCOR::Country < ApplicationRecord
  extend FriendlyId

  REGIONS = [
    'Africa',
    'Asia',
    'Europe',
    'Latin America and Caribbean',
    'North America',
    'Oceania'
  ].freeze
  LENDING_GROUPS = [
    'High-income economies',
    'Upper-middle-income economies',
    'Lower-middle-income economies'
  ].freeze
  MONITOR_CATEGORIES = [
    'Advanced economies',
    'Emerging market economies',
    'Low-income developing countries'
  ].freeze

  friendly_id :name, use: [:slugged, :history], routes: :default

  has_many :benchmarks, class_name: 'ASCOR::Benchmark', foreign_key: :country_id, dependent: :destroy
  has_many :pathways, class_name: 'ASCOR::Pathway', foreign_key: :country_id, dependent: :destroy
  has_many :assessments, class_name: 'ASCOR::Assessment', foreign_key: :country_id, dependent: :destroy

  validates_presence_of :name, :slug, :iso, :region, :wb_lending_group, :fiscal_monitor_category
  validates_uniqueness_of :name, :slug, :iso
  validates :region, inclusion: {in: REGIONS}, allow_nil: true
  validates :wb_lending_group, inclusion: {in: LENDING_GROUPS}, allow_nil: true
  validates :fiscal_monitor_category, inclusion: {in: MONITOR_CATEGORIES}, allow_nil: true

  def path
    Rails.application.routes.url_helpers.tpi_ascor_path slug
  end
end
