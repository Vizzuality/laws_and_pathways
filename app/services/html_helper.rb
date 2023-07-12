module HTMLHelper
  def strip_outer_div(content)
    return unless content.present?

    content.gsub(/\A<div>(.*)<\/div>\z/su, '\1').strip
  end

  module_function :strip_outer_div
end
