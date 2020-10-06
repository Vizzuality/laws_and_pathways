# == Schema Information
#
# Table name: mq_assessments
#
#  id                  :bigint           not null, primary key
#  company_id          :bigint
#  level               :string           not null
#  notes               :text
#  assessment_date     :date             not null
#  publication_date    :date             not null
#  questions           :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  discarded_at        :datetime
#  methodology_version :integer
#

module MQ
  class Assessment < ApplicationRecord
    include DiscardableModel
    LEVELS = %w[0 1 2 3 4 4STAR].freeze

    belongs_to :company, inverse_of: :mq_assessments

    scope :latest_first, -> { order(assessment_date: :desc) }
    scope :all_publication_dates, -> { distinct.order(publication_date: :desc).pluck(:publication_date) }
    scope :all_methodology_versions, -> { distinct.order(methodology_version: :asc).pluck(:methodology_version) }
    scope :currently_published, -> { where('publication_date <= ?', DateTime.now) }

    validates :level, inclusion: {in: LEVELS}
    validates_presence_of :assessment_date, :publication_date, :level

    def previous
      previous_assessments.last
    end

    def previous_assessments
      # do not use active record relations here
      # keep select and sort by, company - mq assessments will be cached once
      company
        .mq_assessments
        .currently_published
        .select { |a| a.assessment_date < assessment_date }
        .sort_by(&:assessment_date)
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

    # for semantic_fields_for
    def questions_attributes=(attributes)
      return if attributes.empty?

      values = attributes.is_a?(Hash) ? attributes.values : attributes

      self.questions = self[:questions].each_with_index.map do |q_hash, index|
        q_hash.merge(answer: values[index]['answer'])
      end
    end

    def find_answer_by_key(key)
      questions.find { |q| q.key == key }&.answer
    end

    def questions_by_level
      questions.group_by(&:level)
    end
  end
end
