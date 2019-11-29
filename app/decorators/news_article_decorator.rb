class NewsArticleDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_news_article_path(model)
  end
end
