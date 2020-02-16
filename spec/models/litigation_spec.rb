# == Schema Information
#
# Table name: litigations
#
#  id                        :bigint           not null, primary key
#  title                     :string           not null
#  slug                      :string           not null
#  citation_reference_number :string
#  document_type             :string
#  geography_id              :bigint
#  summary                   :text
#  at_issue                  :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  created_by_id             :bigint
#  updated_by_id             :bigint
#  discarded_at              :datetime
#  jurisdiction              :string
#

require 'rails_helper'

RSpec.describe Litigation, type: :model do
  subject { build(:litigation) }

  it { is_expected.to be_valid }

  it 'should be invalid if title is nil' do
    subject.title = nil
    expect(subject).to have(1).errors_on(:title)
  end

  it 'should be invalid if document_type is nil' do
    subject.document_type = nil
    expect(subject).to have(1).errors_on(:document_type)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(2).errors_on(:visibility_status)
  end

  it 'should update slug when editing title' do
    litigation = create(:litigation, title: 'Some title')
    expect(litigation.slug).to eq('some-title')
    litigation.update!(title: 'New title')
    expect(litigation.slug).to eq('new-title')
  end

  context 'full_text_search' do
    let!(:litigation_1) {
      create(
        :litigation,
        title: 'Charles & Howard Pty. Ltd. v. Redland Shire Council',
        summary: "The owner of property located on Australia's northwest coast. Łąka"
      )
    }
    let!(:litigation_2) {
      create(
        :litigation,
        title: 'Able Lott Holdings Pty. Ltd. v. City of Fremantle',
        summary: 'This case concerned a development application',
        litigation_sides: [
          build(:litigation_side, name: 'Not real side name, only testing')
        ]
      )
    }
    let!(:litigation_3) {
      create(
        :litigation,
        title: 'Anvil Hill Project Watch Association v. Minister for the Environment',
        summary: 'Under section 75(1) of the Environmental Protection and Biodiversity Conservation',
        keywords: [
          build(:keyword, name: 'Super keyword')
        ]
      )
    }

    it 'ignores accents' do
      expect(Litigation.full_text_search('Laka')).to contain_exactly(litigation_1)
    end

    it 'uses title' do
      expect(Litigation.full_text_search('Pty')).to contain_exactly(litigation_1, litigation_2)
    end

    it 'uses summary' do
      expect(Litigation.full_text_search('Environment')).to contain_exactly(litigation_3)
    end

    it 'uses litigation cases side names' do
      expect(Litigation.full_text_search('side name')).to contain_exactly(litigation_2)
    end

    it 'uses tags' do
      expect(Litigation.full_text_search('keyword')).to contain_exactly(litigation_3)
    end
  end
end
