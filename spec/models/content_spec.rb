# == Schema Information
#
# Table name: contents
#
#  id           :bigint           not null, primary key
#  title        :string
#  text         :text
#  page_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_type :string
#  position     :integer
#  code         :string
#

require 'rails_helper'

RSpec.describe Content, type: :model do
  subject { build(:content, page: build(:tpi_page)) }

  it { is_expected.to be_valid }

  it 'should not be valid without page' do
    subject.page = nil
    expect(subject).to have(1).errors_on(:page)
  end
end
