# == Schema Information
#
# Table name: legislations
#
#  id                :bigint           not null, primary key
#  title             :string
#  description       :text
#  law_id            :integer
#  slug              :string           not null
#  geography_id      :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  visibility_status :string           default("draft")
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  discarded_at      :datetime
#  legislation_type  :string           not null
#  parent_id         :bigint
#

require 'rails_helper'

RSpec.describe Legislation, type: :model do
  subject { build(:legislation) }

  it { is_expected.to be_valid }

  it 'should be invalid without geography' do
    subject.geography = nil
    expect(subject).to have(1).errors_on(:geography)
  end

  it 'should be invalid if title is nil' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(2).errors_on(:visibility_status)
  end

  it 'should be invalid if legislation_type is wrong' do
    expect {
      subject.legislation_type = 'WRONG'
    }.to raise_error(ArgumentError)
  end

  it 'should update slug when editing title' do
    legislation = create(:legislation, title: 'Some title')
    expect(legislation.slug).to eq('some-title')
    legislation.update!(title: 'New title')
    expect(legislation.slug).to eq('new-title')
  end
end
