module ActiveAdminCustomHeader
  def build(*args)
    super(*args)
    render 'admin/custom_header'
  end
end
