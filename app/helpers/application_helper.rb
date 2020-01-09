module ApplicationHelper
  def humanize_boolean(value)
    value ? 'Yes' : 'No'
  end

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

  def active_menu_page?(**args)
    unless args.nil?
      has_pages = false
      has_path = false

      has_pages = args[:pages].any? { |page| current_page?(page[:slug]) } unless args[:pages].nil?

      has_path = current_page?(args[:path]) unless args[:path].nil?

      return has_pages || has_path
    end

    current_page?(
      controller: params[:controller],
      action: params[:action]
    )
  end
end
