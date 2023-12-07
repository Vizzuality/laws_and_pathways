# == Schema Information
#
# Table name: ascor_pathways
#
#  id                     :bigint           not null, primary key
#  country_id             :bigint           not null
#  emissions_metric       :string
#  emissions_boundary     :string
#  units                  :string
#  assessment_date        :date
#  publication_date       :date
#  last_historical_year   :integer
#  trend_1_year           :string
#  trend_3_year           :string
#  trend_5_year           :string
#  emissions              :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  trend_source           :string
#  trend_year             :integer
#  recent_emission_level  :string
#  recent_emission_source :string
#  recent_emission_year   :integer
#
class ASCOR::Pathway < ApplicationRecord
  include HasEmissions

  belongs_to :country, class_name: 'ASCOR::Country', foreign_key: :country_id

  validates_presence_of :emissions_metric, :emissions_boundary, :units, :assessment_date
  validates :emissions_metric, inclusion: {in: ASCOR::EmissionsMetric::VALUES}, allow_nil: true
  validates :emissions_boundary, inclusion: {in: ASCOR::EmissionsBoundary::VALUES}, allow_nil: true

  scope :currently_published, -> { where('ascor_pathways.publication_date <= ?', DateTime.now) }
end
