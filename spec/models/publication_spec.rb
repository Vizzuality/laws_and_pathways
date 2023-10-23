# == Schema Information
#
# Table name: publications
#
#  id                :bigint           not null, primary key
#  title             :string
#  short_description :text
#  file              :bigint
#  image             :bigint
#  publication_date  :datetime
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  author            :string
#  slug              :text             not null
#  summary           :text
#

require 'rails_helper'

RSpec.describe Publication, type: :model do
  subject { build(:publication) }

  it { is_expected.to be_valid }

  it 'should be invalid without file' do
    subject.file = nil
    expect(subject).to have(1).errors_on(:file)
  end

  it 'should be invalid without title' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should be invalid without short_description' do
    subject.short_description = nil
    expect(subject).to have(1).errors_on(:short_description)
  end

  it 'should be invalid without publication date' do
    subject.publication_date = nil
    expect(subject).to have(1).errors_on(:publication_date)
  end
end
