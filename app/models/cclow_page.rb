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
#  position    :integer
#

class CCLOWPage < Page
  MENU_HEADERS = %w[
    header
    footer
    both
  ].freeze
  enum menu: array_to_enum_hash(MENU_HEADERS)
  validates :title, uniqueness: true, presence: true
  validates :slug, uniqueness: true, presence: true

  def admin_path
    'admin_cclow_page_path'
  end
end
