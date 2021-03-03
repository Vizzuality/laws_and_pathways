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
#

module CP
  class Benchmark < ApplicationRecord
    include HasEmissions
    include TPICache

    belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'

    scope :latest_first, -> { order(release_date: :desc) }
    scope :by_release_date, -> { order(:release_date) }

    validates_presence_of :release_date, :scenario

    def unit
      sector.cp_unit_valid_for_date(release_date)&.unit
    end
  end
end
