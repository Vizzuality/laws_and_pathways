class TPIPage < Page
  MENU_HEADERS = %w[
    tpi_tool
    about
  ].freeze
  validates :menu, presence: true

  enum menu: array_to_enum_hash(MENU_HEADERS)

  def slug_path
    "/tpi/#{slug}"
  end

  def admin_path
    'admin_tpi_page_path'
  end
end
