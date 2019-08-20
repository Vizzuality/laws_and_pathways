# == Schema Information
#
# Table name: events
#
#  id             :bigint           not null, primary key
#  eventable_type :string
#  eventable_id   :bigint
#  title          :string           not null
#  event_type     :string           not null
#  date           :date             not null
#  url            :text
#  description    :text
#

FactoryBot.define do
  factory :event do
    url { 'https://test.com' }
    date { 10.days.ago }

    factory :litigation_event do
      title { 'Some case was started' }
      description { 'Description of starting the case' }
      event_type { 'CaseStarted' }
      eventable { |e| e.association(:litigation) }
    end
  end
end
