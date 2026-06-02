# == Schema Information
#
# Table name: cp_benchmarks
#
#  id           :bigint           not null, primary key
#  sector_id    :bigint
#  release_date :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  emissions    :jsonb
#  scenario     :string
#  region       :string           default("Global"), not null
#  category     :string           not null
#  subsector    :string
#

module CP
  class Benchmark < ApplicationRecord
    include HasEmissions
    include TPICache

    REGIONS = %w[
      Europe
      Global
      North-America
      OECD
      non-OECD
    ].freeze

    CHEMICALS_STANDARD_SUBSECTORS = [
      'primary chemicals',
      'non-primary chemicals',
      'agricultural chemicals'
    ].freeze

    belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'

    scope :latest_first, -> { order(release_date: :desc) }
    scope :by_release_date, -> { order(:release_date) }
    scope :companies, -> { where(category: 'Company') }
    scope :banks, -> { where(category: 'Bank') }

    scope :exportable_for_sector_download, -> {
      chemicals_id = Rails.cache.fetch('chemicals_sector_id', expires_in: 1.hour) do
        TPISector.find_by(name: 'Chemicals')&.id
      end

      return all unless chemicals_id

      where.not(sector_id: chemicals_id)
        .or(
          where(sector_id: chemicals_id)
            .where('LOWER(subsector) IN (?) OR subsector IS NULL', CHEMICALS_STANDARD_SUBSECTORS)
        )
    }

    validates_presence_of :release_date, :scenario, :category
    validates :region, inclusion: {in: REGIONS}

    def benchmark_id
      [
        regional? ? region : nil,
        subsector.presence || sector.name,
        release_date
      ].compact.join('_')
    end

    def unit
      sector.cp_unit_valid_for_date(release_date)&.unit
    end

    def regional?
      region.present? && region != 'Global'
    end

    def for_alignment?(alignment)
      return false unless alignment.present?

      CP::Alignment.new(name: scenario).standarized_name == CP::Alignment.new(name: alignment).standarized_name
    end
  end
end
