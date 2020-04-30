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
#  discarded_at   :datetime
#

FactoryBot.define do
  factory :event do
    url { 'https://test.com' }
    date { 10.days.ago }
    title { 'Lorem ipsum' }

    factory :litigation_event do
      title { 'Some case was started' }
      description { 'Description of starting the case' }
      event_type { 'case_started' }
      eventable { |e| e.association(:litigation) }
    end

    factory :legislation_event do
      title { 'Some law was approved' }
      description { 'Description of approved law' }
      event_type { 'passed/approved' }
      eventable { |e| e.association(:legislation) }
    end

    factory :target_event do
      title { 'Some target was set' }
      description { 'Description of target event' }
      event_type { 'set' }
      eventable { |e| e.association(:target) }
    end

    factory :geography_event do
      title { 'Barcelona event' }
      description { 'Description of event' }
      event_type { 'election' }
      eventable { |e| e.association(:geography) }
    end
  end
end
