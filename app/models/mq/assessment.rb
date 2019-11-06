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
#  discarded_at     :datetime
#

module MQ
  class Assessment < ApplicationRecord
    include DiscardableModel
    LEVELS = %w[0 1 2 3 4 4STAR].freeze

    belongs_to :company, inverse_of: :mq_assessments

    scope :latest_first, -> { order(assessment_date: :desc) }
    scope :all_publication_dates, -> { distinct.order(publication_date: :desc).pluck(:publication_date) }

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
      "#{level} (#{status.upcase})"
    end

    def questions
      return unless self[:questions].present?

      @questions ||= self[:questions].each_with_index.map do |q_hash, index|
        MQ::Question.new(q_hash.merge(number: index + 1))
      end
    end

    def questions=(value)
      @questions = nil
      super
    end

    def find_answer_by_key(key)
      questions.find { |q| q.key == key }.answer
    end

    def questions_by_level
      questions.group_by(&:level)
    end
  end
end
