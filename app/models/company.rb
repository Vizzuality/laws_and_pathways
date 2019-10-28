# == Schema Information
#
# Table name: companies
#
#  id                        :bigint           not null, primary key
#  geography_id              :bigint
#  headquarters_geography_id :bigint
#  sector_id                 :bigint
#  name                      :string           not null
#  slug                      :string           not null
#  isin                      :string           not null
#  size                      :string
#  ca100                     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  discarded_at              :datetime
#

class Company < ApplicationRecord
  include DiscardableModel
  include VisibilityStatus
  extend FriendlyId
  friendly_id :name, use: :slugged, routes: :default

  SIZES = %w[small medium large].freeze

  enum size: array_to_enum_hash(SIZES)

  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'
  belongs_to :geography
  belongs_to :headquarters_geography, class_name: 'Geography'

  has_many :mq_assessments, class_name: 'MQ::Assessment', inverse_of: :company
  has_many :cp_assessments, class_name: 'CP::Assessment', inverse_of: :company
  has_many :litigation_sides, as: :connected_entity
  has_many :litigations, through: :litigation_sides

  delegate :level, :status, :status_description_short,
           to: :latest_mq_assessment, prefix: :mq, allow_nil: true

  validates :ca100, inclusion: {in: [true, false]}
  validates_presence_of :name, :slug, :isin, :size
  validates_uniqueness_of :slug, :isin, :name

  def to_s
    name
  end

  def latest_mq_assessment
    mq_assessments.order(:assessment_date).last
  end

  def oldest_mq_assessment
    mq_assessments.order(:assessment_date).first
  end

  def latest_cp_assessment
    cp_assessments.order(:assessment_date).last
  end

  def latest_sector_benchmarks
    sector.latest_released_benchmarks
  end

  # Returns sector CP benchmarks:
  # - from the last date before latest CP::Assessment date
  #   (if company latest CP::Assessment was after at least one benchmark)
  # - from latest benchmarks otherwise
  #
  # @return [AssociationRelation [#<CP::Benchmark]
  #
  # @example Company has assessment:
  # - benchmarks available for 04.2017 and 05.2018
  # - if assessment date is 06.2018 - we take benchmarks from 05.2018
  # - if assessment date is 06.2017 - we take benchmarks from 04.2017
  def latest_sector_benchmarks_before_last_assessment
    last_assessment_date = latest_cp_assessment&.assessment_date

    return sector.latest_released_benchmarks unless last_assessment_date

    sector_benchmarks_dates = sector.cp_benchmarks.pluck(:release_date).uniq.sort

    last_release_date_before_assessment =
      sector_benchmarks_dates
        .select { |d| d < last_assessment_date }
        .last

    release_date =
      last_release_date_before_assessment || sector_benchmarks_dates.last

    sector.cp_benchmarks.where(release_date: release_date)
  end
end
