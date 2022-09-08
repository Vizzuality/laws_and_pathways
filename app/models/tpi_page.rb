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

class TPIPage < Page
  MENU_HEADERS = %w[
    tpi_tool
    about
    about_tpi_centre
    about_tpi_ltd
    no_menu_entry
  ].freeze
  enum menu: array_to_enum_hash(MENU_HEADERS)

  validates :slug, uniqueness: true, presence: true
  validates :title, uniqueness: true, presence: true

  def admin_path
    'admin_tpi_page_path'
  end

  def to_menu_entry
    slice(:path, :title)
  end
end
