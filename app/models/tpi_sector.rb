# == Schema Information
#
# Table name: tpi_sectors
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cluster_id       :bigint
#  show_in_tpi_tool :boolean          default(TRUE), not null
#  categories       :string           default([]), is an Array
#

class TPISector < ApplicationRecord
  include TPICache
  extend FriendlyId

  CATEGORIES = %w[Company Bank].freeze

  friendly_id :name, use: [:slugged, :history], routes: :default

  belongs_to :cluster, class_name: 'TPISectorCluster', foreign_key: 'cluster_id', optional: true

  has_many :companies, foreign_key: 'sector_id'
  has_many :cp_assessments, class_name: 'CP::Assessment', foreign_key: 'sector_id'
  has_many :cp_benchmarks, class_name: 'CP::Benchmark', foreign_key: 'sector_id'
  has_many :cp_units, class_name: 'CP::Unit', foreign_key: 'sector_id', inverse_of: :sector
  has_many :subsectors, foreign_key: 'sector_id'

  has_and_belongs_to_many :publications
  has_and_belongs_to_many :news_articles

  accepts_nested_attributes_for :cp_units, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates :categories, array_inclusion: {in: CATEGORIES}

  scope :tpi_tool, -> { where(show_in_tpi_tool: true) }
  scope :for_category, ->(klass) { where('categories && ARRAY[?]::varchar[]', klass.to_s) }
  scope :companies, -> { for_category Company }
  scope :banks, -> { for_category Bank }
  scope :with_companies, -> { joins(:companies).where(companies: Company.published).distinct }

  def should_generate_new_friendly_id?
    (show_in_tpi_tool? && name_changed?) || super
  end

  def cp_unit_valid_for_date(date)
    return latest_cp_unit unless date

    cp_units
      .select { |u| u.valid_since.nil? || u.valid_since <= date }
      .max_by { |u| u.valid_since || Date.new(1900, 1, 1) }
  end

  def latest_cp_unit
    cp_units.order('valid_since DESC NULLS LAST').first
  end

  def latest_released_benchmarks(category:, region: nil, subsector: nil)
    region ||= 'Global'
    scope = cp_benchmarks.where(category: category.to_s, region: region)
    scope = scope.where(subsector: subsector) unless subsector.nil?
    last = scope.group_by(&:release_date).max
    last ? last.last : []
  end

  def publications_and_articles
    (publications + news_articles)
      .sort { |a, b| b.publication_date <=> a.publication_date }[0, 3]
  end

  # Returns sector CP benchmarks:
  # - from the last date before latest CP::Assessment date
  #   (if company latest CP::Assessment was after at least one benchmark)
  # - from first benchmarks otherwise
  #
  # @return [AssociationRelation [#<CP::Benchmark]
  #
  # @example Company has assessment:
  # - benchmarks available for 04.2017 and 05.2018
  # - if assessment publication date is 06.2018 - we take benchmarks from 05.2018
  # - if assessment publication date is 06.2017 - we take benchmarks from 04.2017
  # - if assessment publication date is 03.2017 - we take benchmarks from 04.2017
  def latest_benchmarks_for_date(date, category:, region: nil, subsector: nil)
    region ||= 'Global'
    return latest_released_benchmarks(category: category, region: region, subsector: subsector) unless date

    benchmarks = cp_benchmarks.where(category: category.to_s, region: region, subsector: subsector)
    sector_benchmarks_dates = benchmarks.pluck(:release_date).uniq.sort

    last_release_date_before_given_date =
      sector_benchmarks_dates
        .select { |d| d <= date }
        .last

    release_date =
      last_release_date_before_given_date || sector_benchmarks_dates.first

    benchmarks.where(release_date: release_date).order(:created_at)
  end

  def path
    return Rails.application.routes.url_helpers.tpi_banks_path if slug == 'banks'

    Rails.application.routes.url_helpers.tpi_sector_path(slug)
  end

  def self.search(query)
    where('name ilike ?', "%#{query}%")
  end

  def available_subsectors
    CompanySubsector.joins(:company)
      .where(companies: {sector_id: id})
      .distinct
      .pluck(:subsector)
      .sort
  end
end
