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

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}#{rand(99_999)}@example.com" }
    first_name { 'Bobby' }
    last_name { 'Example' }
    role { 'super_user' }
    password { 'secret' }

    AdminUser::ROLES.each do |role|
      trait role.to_sym do
        role { role }
      end
    end
  end
end
