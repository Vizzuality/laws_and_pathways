module Site
  Breadcrumb = Struct.new(:title, :path) do
    def short_title
      ActionController::Base.helpers.truncate(title, length: 100)
    end
  end
end
