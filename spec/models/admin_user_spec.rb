# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#

require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  subject { build(:admin_user) }

  it { is_expected.to be_valid }

  it 'should be invalid without email' do
    subject.email = nil
    expect(subject).to have(1).errors_on(:email)
  end

  it 'should be invalid without role' do
    subject.role = nil
    expect(subject).to have(2).errors_on(:role)
  end
end
