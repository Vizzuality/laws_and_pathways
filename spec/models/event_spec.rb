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

require 'rails_helper'

RSpec.describe Event, type: :model do
  subject { build(:event) }

  it 'should not be valid without title' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should not be valid without event_type' do
    subject.event_type = nil
    # 2 errors because event type inclusion
    expect(subject).to have(2).errors_on(:event_type)
  end

  describe 'Litigation Event' do
    subject { build(:litigation_event) }

    it 'should be valid' do
      expect(subject).to be_valid
    end

    it 'should not be valid with wrong type' do
      subject.event_type = 'NotListed'
      expect(subject).to have(1).errors_on(:event_type)
    end
  end
end
