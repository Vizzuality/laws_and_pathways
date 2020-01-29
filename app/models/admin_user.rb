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

class AdminUser < ApplicationRecord
  # Include default devise modules.
  # Others available are: :confirmable, :lockable, :timeoutable, :trackable & :omniauthable.
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable

  ROLES = %w[super_user publisher_laws publisher_tpi editor_laws editor_tpi].freeze

  validates_presence_of :role
  validates :role, inclusion: {in: ROLES}

  delegate :authorize!, :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end

  def gravatar_url(size = 50)
    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    to_s
  end

  def to_s
    return email if full_name.blank?

    full_name
  end
end
