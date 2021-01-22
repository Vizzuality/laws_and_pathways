class HashDecorator < Draper::Decorator
  def key_values
    rows = model
      .map { |k, v| "<p>#{k.humanize}: <strong>#{v}</strong></p>" }
      .join('')

    rows.html_safe
  end
end
