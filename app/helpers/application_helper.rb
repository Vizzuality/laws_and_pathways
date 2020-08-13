module ApplicationHelper
  def humanize_boolean(value)
    value ? 'Yes' : 'No'
  end

  def render_breadcrumb
    return unless defined?(@breadcrumb)

    content_tag :div, class: 'breadcrumb has-succeeds-separator is-hidden-touch' do
      content_tag :ul do
        @breadcrumb.each_with_index.map do |item, i|
          content_tag :li, class: i.eql?(@breadcrumb.count - 1) ? 'is-active' : '' do
            link_to item.short_title, item.path, title: item.title
          end
        end.join.html_safe
      end
    end
  end

  def active_menu_page?(pages)
    Array.wrap(pages).any? do |page|
      current_page?(page)
    rescue ActionController::UrlGenerationError
      false
    end
  end
end
