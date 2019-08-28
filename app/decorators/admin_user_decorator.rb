class AdminUserDecorator < Draper::Decorator
  delegate_all

  def gravatar
    h.image_tag model.gravatar_url, title: model.to_s
  end
end
