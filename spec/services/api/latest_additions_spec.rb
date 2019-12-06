require 'rails_helper'

RSpec.describe Api::LatestAdditions do
  before do
    create(:legislation, visibility_status: 'published')
    create(:litigation, :with_events, visibility_status: 'published')
  end

  subject { described_class.new(1).call }

  describe 'latest_additions' do
    it 'latest additions have current count' do
      expect(subject.count).to eq(2)
    end

    it 'latest additions have current keys' do
      expect(subject.first.keys).to contain_exactly(:kind, :title, :iso, :date_passed,
                                                    :addition_type, :jurisdiction, :link)
    end
  end
end
