module CP
  class Assessment < ApplicationRecord
    belongs_to :company

    scope :latest_first, -> { order(assessment_date: :desc) }

    validates_presence_of :publication_date

    # emissions is a hash like { year => value }, this method returns all years
    def emissions_all_years
      return [] unless emissions.present?

      emissions.keys
    end
  end
end
