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
      let(:admin_user) { create(:admin_user, role: 'editor_tpi') }

      context 'when creating' do
        context 'can' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.to be_able_to(:create, resource) }
          end
        end

        context 'can not' do
          Ability::LAWS_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:create, resource) }
          end
        end
      end

      context 'when updating' do
        context 'can' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.to be_able_to(:update, resource) }
          end
        end

        context 'can not' do
          Ability::LAWS_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:update, resource) }
          end
        end
      end

      context 'when updating users' do
        let(:other_editor) { create(:admin_user, role: 'editor_tpi') }

        context 'can' do
          it 'is expected to be able to modify himself' do
            is_expected.to be_able_to(:modify, admin_user)
          end
        end

        context 'can not' do
          it 'is expected not to be able to modify other Editors' do
            is_expected.not_to be_able_to(:modify, other_editor)
          end
        end
      end

      context 'when archiving' do
        context 'can' do
          it { is_expected.to be_able_to(:archive, Company) }
        end

        context 'can not' do
          Ability::LAWS_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
          end

          (Ability::TPI_RESOURCES - Ability::PUBLISHABLE_RESOURCES).each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
          end
        end
      end
    end

    context 'when user is LAWS editor' do
      let(:admin_user) { build(:admin_user, role: 'editor_laws') }

      context 'when creating' do
        context 'can' do
          Ability::LAWS_RESOURCES.each do |resource|
            it { is_expected.to be_able_to(:create, resource) }
          end
        end

        context 'can not' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:create, resource) }
          end

          it { is_expected.not_to be_able_to(:create, AdminUser) }
        end
      end

      context 'when updating' do
        context 'can' do
          Ability::LAWS_RESOURCES.each do |resource|
            it { is_expected.to be_able_to(:update, resource) }
          end
        end

        context 'can not' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:update, resource) }
          end
        end
      end

      context 'when updating users' do
        let(:other_editor) { create(:admin_user, role: 'editor_laws') }

        context 'can' do
          it 'is expected to be able to modify himself' do
            is_expected.to be_able_to(:modify, admin_user)
          end
        end

        context 'can not' do
          it 'is expected not to be able to modify other Editors' do
            is_expected.not_to be_able_to(:modify, other_editor)
          end
        end
      end

      context 'when archiving' do
        context 'can' do
          it { is_expected.to be_able_to(:archive, Legislation) }
          it { is_expected.to be_able_to(:archive, Litigation) }
          it { is_expected.to be_able_to(:archive, Target) }
        end

        context 'can not' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
          end

          (Ability::LAWS_RESOURCES - Ability::PUBLISHABLE_RESOURCES).each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
          end
        end
      end
    end

    context 'when user is TPI publisher' do
      let(:admin_user) { build(:admin_user, role: 'publisher_tpi') }

      context 'when managing' do
        context 'can' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.to be_able_to(:crud, resource) }
          end

          it { is_expected.to be_able_to(:crud, Tag) }
          it { is_expected.to be_able_to(:create, AdminUser) }
        end
      end

      context 'when updating users' do
        let(:other_publisher) { create(:admin_user, role: 'publisher_tpi') }

        context 'can' do
          it 'is expected to be able to modify himself' do
            is_expected.to be_able_to(:modify, admin_user)
          end
        end

        context 'can not' do
          it 'is expected not to be able to modify other Publishers' do
            is_expected.not_to be_able_to(:modify, other_publisher)
          end
        end
      end

      context 'when archiving / publishing' do
        context 'can' do
          it { is_expected.to be_able_to(:archive, Company) }
          it { is_expected.to be_able_to(:publish, Company) }
        end

        context 'can not' do
          Ability::LAWS_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
            it { is_expected.not_to be_able_to(:publish, resource) }
          end

          (Ability::TPI_RESOURCES - Ability::PUBLISHABLE_RESOURCES).each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
            it { is_expected.not_to be_able_to(:publish, resource) }
          end
        end
      end
    end

    context 'when user is LAWS publisher' do
      let(:admin_user) { build(:admin_user, role: 'publisher_laws') }

      context 'when managing' do
        context 'can' do
          Ability::LAWS_RESOURCES.each do |resource|
            it { is_expected.to be_able_to(:crud, resource) }
          end

          it { is_expected.to be_able_to(:crud, Tag) }
          it { is_expected.to be_able_to(:create, AdminUser) }
        end

        context 'can not' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:crud, resource) }
          end
        end
      end

      context 'when updating users' do
        let(:other_publisher) { create(:admin_user, role: 'publisher_laws') }

        context 'can' do
          it 'is expected to be able to modify himself' do
            is_expected.to be_able_to(:modify, admin_user)
          end
        end

        context 'can not' do
          it 'is expected not to be able to modify other Publishers' do
            is_expected.not_to be_able_to(:modify, other_publisher)
          end
        end
      end

      context 'when archiving / publishing' do
        context 'can' do
          it { is_expected.to be_able_to(:archive, Legislation) }
          it { is_expected.to be_able_to(:publish, Legislation) }
          it { is_expected.to be_able_to(:archive, Litigation) }
          it { is_expected.to be_able_to(:publish, Litigation) }
          it { is_expected.to be_able_to(:archive, Target) }
          it { is_expected.to be_able_to(:publish, Target) }
        end

        context 'can not' do
          Ability::TPI_RESOURCES.each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
            it { is_expected.not_to be_able_to(:publish, resource) }
          end

          (Ability::LAWS_RESOURCES - Ability::PUBLISHABLE_RESOURCES).each do |resource|
            it { is_expected.not_to be_able_to(:archive, resource) }
            it { is_expected.not_to be_able_to(:publish, resource) }
          end
        end
      end
    end
  end
end
