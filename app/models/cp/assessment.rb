# == Schema Information
#
# Table name: cp_assessments
#
#  id                 :bigint           not null, primary key
#  company_id         :bigint
#  publication_date   :date             not null
#  assessment_date    :date
#  emissions          :jsonb
#  assumptions        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#  last_reported_year :integer
#  cp_alignment       :string
#

module CP
  class Assessment < ApplicationRecord
    include HasEmissions
    include DiscardableModel

    belongs_to :company

    scope :latest_first, -> { order(assessment_date: :desc) }
    scope :all_publication_dates, -> { distinct.order(publication_date: :desc).pluck(:publication_date) }
    scope :published_on_or_before, lambda { |publication_date|
      order(:publication_date).where('publication_date <= ?', publication_date)
    }
    scope :currently_published, -> { where('publication_date <= ?', DateTime.now) }

    validates_presence_of :publication_date
    validates :assessment_date, date_after: Date.new(2010, 12, 31)
    validates :publication_date, date_after: Date.new(2010, 12, 31)

    def unit
      company.sector.cp_unit_valid_for_date(publication_date)&.unit
    end
  end
end
