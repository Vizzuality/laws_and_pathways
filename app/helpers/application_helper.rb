module ApplicationHelper
  def render_breadcrumb
    return unless defined?(@breadcrumb)

    content_tag :div, class: 'breadcrumb' do
      @breadcrumb.map do |item|
        link_to item.title, item.path
      end.join(' > ').html_safe
    end
  end
end
