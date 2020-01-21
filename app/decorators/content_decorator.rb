class ContentDecorator < Draper::Decorator
  delegate_all

  def youtube_iframe(width, height)
    %(<iframe width="#{width}" height="#{height}" src="//www.youtube.com/embed/#{youtube_id}"
      frameborder="0" allowfullscreen></iframe>).html_safe
  end

  def youtube_image
    return unless model.youtube_link.present?

    h.image_tag("https://i.ytimg.com/vi/#{youtube_id}/default.jpg")
  end

  private

  def youtube_id
    regex = /^(http[s]*:\/\/)?(www.)?(youtube.com|youtu.be)\/(watch\?v=){0,1}([a-zA-Z0-9_-]{11})/
    matches = regex.match model.youtube_link.to_str
    matches && matches[6] || matches[5]
  end
end
