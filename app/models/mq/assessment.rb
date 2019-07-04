# == Schema Information
#
# Table name: mq_assessments
#
#  id               :bigint(8)        not null, primary key
#  company_id       :bigint(8)
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
    belongs_to :company, inverse_of: :mq_assessments

    scope :latest_first, -> { order(assessment_date: :desc) }

    def previous
      company.mq_assessments.second
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
