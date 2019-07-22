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

FactoryBot.define do
  factory :mq_assessment, class: MQ::Assessment do
    association :company

    assessment_date { 1.year.ago }
    publication_date { 11.months.ago }

    level { '1' }
    notes { 'Some notes' }

    questions do
      get_question_level = lambda do |nr|
        return '0' if (0..1).include?(nr)
        return '1' if (2..4).include?(nr)
        return '3' if (5..8).include?(nr)

        '4'
      end

      (1..14).map do |nr|
        {
          level: get_question_level.call(nr),
          question: "Question nr #{nr}",
          answer: %w[Yes No].sample
        }
      end
    end
  end
end
