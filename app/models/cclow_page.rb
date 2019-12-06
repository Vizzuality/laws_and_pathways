class CCLOWPage < Page
  def slug_path
    "/cclow/#{slug}"
  end

  def admin_path
    "admin_cclow_page_path"
  end
end
