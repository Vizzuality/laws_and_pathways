module MQ
  class Assessment < ApplicationRecord
    store_accessor :form, :questions

    scope :latest_first, -> { order(assessment_date: :desc) }
  end
end
