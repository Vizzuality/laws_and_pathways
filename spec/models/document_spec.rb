# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  type              :string           not null
#  external_url      :text
#  language          :string
#  last_verified_on  :date
#  documentable_type :string
#  documentable_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  discarded_at      :datetime
#

require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { build(:document) }

  it 'should not be valid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should not be valid without type' do
    subject.type = nil
    expect(subject).to have(1).errors_on(:type)
  end

  describe 'uploaded' do
    subject { build(:document_uploaded) }

    it { is_expected.to be_valid }

    it 'should be invalid without file' do
      subject.file = nil
      expect(subject).to have(1).errors_on(:file)
    end
  end

  describe 'external' do
    subject { build(:document) }

    it { is_expected.to be_valid }

    it 'should not be valid without external_url' do
      subject.external_url = nil
      expect(subject).to have(1).errors_on(:external_url)
    end

    it 'should be invalid if external_url is not a valid URL' do
      subject.external_url = 'not a valid external_url'
      expect(subject).to have(1).errors_on(:external_url)
    end
  end
end
