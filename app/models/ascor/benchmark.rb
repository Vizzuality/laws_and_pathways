# == Schema Information
#
# Table name: ascor_benchmarks
#
#  id                 :bigint           not null, primary key
#  country_id         :bigint           not null
#  publication_date   :date
#  emissions_metric   :string
#  emissions_boundary :string
#  units              :string
#  benchmark_type     :string
#  emissions          :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class ASCOR::Benchmark < ApplicationRecord
  include HasEmissions

  belongs_to :country, class_name: 'ASCOR::Country', foreign_key: :country_id

  validates_presence_of :emissions_metric, :emissions_boundary, :units, :benchmark_type
  validates :emissions_metric, inclusion: {in: ASCOR::EmissionsMetric::VALUES}, allow_nil: true
  validates :emissions_boundary, inclusion: {in: ASCOR::EmissionsBoundary::VALUES}, allow_nil: true
  validates :benchmark_type, inclusion: {in: ASCOR::BenchmarkType::VALUES}, allow_nil: true
end
