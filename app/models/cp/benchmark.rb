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
    belongs_to :sector

    scope :latest_first, -> { order(release_date: :desc) }
    scope :by_release_date, -> { order(:release_date) }

    validates_presence_of :release_date, :scenario

    def emissions_all_years
      emissions.keys
    end

    def emissions=(value)
      if value.is_a?(String)
        write_attribute(:emissions, JSON.parse(value))
      else
        super
      end
    end
  end
end
