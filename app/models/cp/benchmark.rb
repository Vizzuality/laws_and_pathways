# == Schema Information
#
# Table name: cp_benchmarks
#
#  id         :bigint(8)        not null, primary key
#  sector_id  :bigint(8)
#  date       :date
#  benchmarks :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module CP
  class Benchmark < ApplicationRecord
    belongs_to :sector

    validates_presence_of :date
  end
end
