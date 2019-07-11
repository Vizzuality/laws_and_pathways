# == Schema Information
#
# Table name: cp_benchmarks
#
#  id         :bigint(8)        not null, primary key
#  sector_id  :bigint(8)
#  date       :date             not null
#  benchmarks :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module CP
  class Benchmark < ApplicationRecord
    belongs_to :sector

    scope :latest_first, -> { order(date: :desc) }
    scope :by_date, -> { order(:date) }

    validates_presence_of :date

    def benchmarks_all_years
      benchmarks.map { |b| b['values'].keys }.flatten.uniq
    end
  end
end
