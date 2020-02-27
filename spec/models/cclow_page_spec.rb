# == Schema Information
#
# Table name: pages
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  slug        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  menu        :string
#  type        :string
#

require 'rails_helper'

RSpec.describe CCLOWPage, type: :model do
  subject { build(:cclow_page) }

  it { is_expected.to be_valid }

  it 'should update slug when editing title' do
    page = create(:cclow_page, title: 'Some name')
    expect(page.slug).to eq('some-name')
    page.update!(title: 'New name')
    expect(page.slug).to eq('new-name')
  end
end
