class TPIPage < Page
  MENU_HEADERS = %w[
    tpi_tool
    about
  ].freeze
  enum menu: array_to_enum_hash(MENU_HEADERS)
  validates :slug, uniqueness: true, presence: true
  validates :title, uniqueness: true, presence: true

  def slug_path
    "/tpi/#{slug}"
  end

  def admin_path
    'admin_tpi_page_path'
  end
end
