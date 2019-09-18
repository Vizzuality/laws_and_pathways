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

    belongs_to :sector

    scope :latest_first, -> { order(release_date: :desc) }
    scope :by_release_date, -> { order(:release_date) }

    validates_presence_of :release_date, :scenario
  end
end
