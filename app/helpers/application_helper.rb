module ApplicationHelper
  def render_breadcrumb
    return unless defined?(@breadcrumb)

    content_tag :div, class: 'breadcrumb has-succeeds-separator' do
      content_tag :ul do
        @breadcrumb.each_with_index.map do |item, i|
          content_tag :li, class: i.eql?(@breadcrumb.count - 1) ? 'is-active' : '' do
            link_to item.title, item.path
          end
        end.join.html_safe
      end
    end
  end
end
