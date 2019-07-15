module CP
  class Assessment < ApplicationRecord
    belongs_to :company

    scope :latest_first, -> { order(assessment_date: :desc) }

    validates_presence_of :publication_date

    def emissions_all_years
      return [] unless emissions.present?

      emissions.keys
    end
  end
end
