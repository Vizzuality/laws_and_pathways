class ASCOR::Country < ApplicationRecord
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

  validates_presence_of :name, :iso, :region, :wb_lending_group, :fiscal_monitor_category
  validates_uniqueness_of :name, :iso
  validates :region, inclusion: {in: REGIONS}, allow_nil: true
  validates :wb_lending_group, inclusion: {in: LENDING_GROUPS}, allow_nil: true
  validates :fiscal_monitor_category, inclusion: {in: MONITOR_CATEGORIES}, allow_nil: true
end
