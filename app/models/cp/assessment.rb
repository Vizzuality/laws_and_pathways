# == Schema Information
#
# Table name: cp_assessments
#
#  id               :bigint           not null, primary key
#  company_id       :bigint
#  publication_date :date             not null
#  assessment_date  :date
#  emissions        :jsonb
#  assumptions      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

module CP
  class Assessment < ApplicationRecord
    include HasEmissions
    include Discardable

    belongs_to :company

    scope :latest_first, -> { order(assessment_date: :desc) }

    validates_presence_of :publication_date

    def self.all_publication_dates
      distinct.order(publication_date: :desc).pluck(:publication_date)
    end
  end
end
