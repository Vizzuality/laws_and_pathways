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

class QuestionFactoryHelper
  def self.get_question_level(num)
    return '0' if (0..1).include?(num)
    return '1' if (2..4).include?(num)
    return '3' if (5..8).include?(num)

    '4'
  end
end

FactoryBot.define do
  factory :mq_assessment, class: MQ::Assessment do
    # association :company

    assessment_date { 1.year.ago.to_date }
    publication_date { 11.months.ago.to_date }

    level { '1' }
    notes { 'Some notes' }
    methodology_version { 1 }

    questions do
      (1..14).map do |nr|
        {
          level: QuestionFactoryHelper.get_question_level(nr),
          question: "Question nr #{nr}",
          answer: %w[Yes No].sample
        }
      end
    end
  end
end
