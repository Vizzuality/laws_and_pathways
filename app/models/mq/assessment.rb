# == Schema Information
#
# Table name: mq_assessments
#
#  id               :bigint           not null, primary key
#  company_id       :bigint
#  level            :string           not null
#  notes            :text
#  assessment_date  :date             not null
#  publication_date :date             not null
#  questions        :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

module MQ
  class Assessment < ApplicationRecord
    LEVELS = %w[0 1 2 3 4 4STAR].freeze

    belongs_to :company, inverse_of: :mq_assessments

    scope :latest_first, -> { order(assessment_date: :desc) }
    scope :by_assessment_date, -> { order(:assessment_date) }

    validates :level, inclusion: {in: LEVELS}
    validates_presence_of :assessment_date, :publication_date, :level

    def previous
      company
        .mq_assessments
        .where('assessment_date < ?', assessment_date)
        .latest_first
        .first
    end

    def status
      return 'new' unless previous.present?
      return 'up' if level > previous.level
      return 'down' if level < previous.level

      'unchanged'
    end

    def status_description_short
      "#{level} (#{status})"
    end
  end
end
