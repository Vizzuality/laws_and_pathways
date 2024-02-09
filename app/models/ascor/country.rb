# == Schema Information
#
# Table name: ascor_countries
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  slug                    :string
#  iso                     :string
#  region                  :string
#  wb_lending_group        :string
#  fiscal_monitor_category :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  type_of_party           :string
#  visibility_status       :string           default("draft")
#
class ASCOR::Country < ApplicationRecord
  include VisibilityStatus
  extend FriendlyId

  LENDING_GROUPS = %w[High-income Upper-middle-income Lower-middle-income Low-income].freeze
  MONITOR_CATEGORIES = [
    'Advanced economies',
    'Emerging market economies',
    'Low-income developing countries'
  ].freeze
  TYPE_OF_PARTY = [
    'Annex I',
    'Non-Annex I',
    'Annex I and Annex II',
    'Non-Annex I and Non-Annex II',
    'Annex I and Non-Annex II'
  ].freeze
  DEFAULT_COUNTRIES = %w[USA CAN GBR FRA DEU ITA JPN RUS].freeze

  friendly_id :name, use: [:slugged, :history], routes: :default

  has_many :benchmarks, class_name: 'ASCOR::Benchmark', foreign_key: :country_id, dependent: :destroy
  has_many :pathways, class_name: 'ASCOR::Pathway', foreign_key: :country_id, dependent: :destroy
  has_many :assessments, class_name: 'ASCOR::Assessment', foreign_key: :country_id, dependent: :destroy

  validates_presence_of :name, :slug, :iso, :region, :wb_lending_group, :fiscal_monitor_category
  validates_uniqueness_of :name, :slug, :iso
  validates :wb_lending_group, inclusion: {in: LENDING_GROUPS}, allow_nil: true
  validates :fiscal_monitor_category, inclusion: {in: MONITOR_CATEGORIES}, allow_nil: true
  validates :type_of_party, inclusion: {in: TYPE_OF_PARTY}, allow_nil: true

  def path
    Rails.application.routes.url_helpers.tpi_ascor_path slug
  end
end
