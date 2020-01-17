require 'rails_helper'

RSpec.describe TPIPage, type: :model do
  subject { build(:tpi_page) }

  it { is_expected.to be_valid }

  it 'should update slug when editing title' do
    page = create(:tpi_page, title: 'Some name')
    expect(page.slug).to eq('some-name')
    page.update!(title: 'New name')
    expect(page.slug).to eq('new-name')
  end
end
