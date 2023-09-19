class ASCOR::Pathway < ApplicationRecord
  include HasEmissions

  belongs_to :country, class_name: 'ASCOR::Country', foreign_key: :country_id

  validates_presence_of :emissions_metric, :emissions_boundary, :land_use, :units, :assessment_date
  validates :emissions_metric, inclusion: {in: ASCOR::EmissionsMetric::VALUES}, allow_nil: true
  validates :emissions_boundary, inclusion: {in: ASCOR::EmissionsBoundary::VALUES}, allow_nil: true
  validates :land_use, inclusion: {in: ASCOR::LandUse::VALUES}, allow_nil: true
end
