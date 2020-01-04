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
#  role                   :string
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

  describe 'abilities' do
    subject(:ability) { Ability.new(admin_user) }

    let(:admin_user) { nil }

    context 'when user is TPI editor' do
      let(:admin_user) { build(:admin_user, role: 'editor_tpi') }

      context 'when creating' do
        Ability::TPI_RESOURCES.each do |resource|
          it { is_expected.to be_able_to(:create, resource) }
        end

        Ability::LAWS_RESOURCES.each do |resource|
          it { is_expected.not_to be_able_to(:create, resource) }
        end
      end

      context 'when updating' do
        Ability::TPI_RESOURCES.each do |resource|
          it { is_expected.to be_able_to(:update, resource) }
        end

        Ability::LAWS_RESOURCES.each do |resource|
          it { is_expected.not_to be_able_to(:update, resource) }
        end
      end

      context 'when archiving' do
        it { is_expected.to be_able_to(:archive, Company) }

        Ability::LAWS_RESOURCES.each do |resource|
          it { is_expected.not_to be_able_to(:archive, resource) }
        end

        (Ability::TPI_RESOURCES - Ability::PUBLISHABLE_RESOURCES).each do |resource|
          it { is_expected.not_to be_able_to(:archive, resource) }
        end
      end
    end

    context 'when user is LAWS editor' do
      let(:admin_user) { build(:admin_user, role: 'editor_laws') }

      context 'when creating' do
        Ability::LAWS_RESOURCES.each do |resource|
          it { is_expected.to be_able_to(:create, resource) }
        end

        Ability::TPI_RESOURCES.each do |resource|
          it { is_expected.not_to be_able_to(:create, resource) }
        end
      end

      context 'when updating' do
        Ability::LAWS_RESOURCES.each do |resource|
          it { is_expected.to be_able_to(:update, resource) }
        end

        Ability::TPI_RESOURCES.each do |resource|
          it { is_expected.not_to be_able_to(:update, resource) }
        end
      end

      context 'when archiving' do
        it { is_expected.to be_able_to(:archive, Legislation) }
        it { is_expected.to be_able_to(:archive, Litigation) }
        it { is_expected.to be_able_to(:archive, Target) }

        Ability::TPI_RESOURCES.each do |resource|
          it { is_expected.not_to be_able_to(:archive, resource) }
        end

        (Ability::LAWS_RESOURCES - Ability::PUBLISHABLE_RESOURCES).each do |resource|
          it { is_expected.not_to be_able_to(:archive, resource) }
        end
      end
    end
  end
end
