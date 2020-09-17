class NewsArticleDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_news_article_path(model)
  end

  def tpi_sector_links
    model.tpi_sectors.map do |sector|
      h.link_to sector.name,
                h.admin_tpi_sector_path(sector),
                target: '_blank',
                title: sector.name
    end
  end

  def preview_url
    h.tpi_publication_url(
      model, {type: 'NewsArticle', host: Rails.configuration.try(:tpi_domain)}.compact
    )
  end
end
