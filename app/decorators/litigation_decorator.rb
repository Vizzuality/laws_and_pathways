class LitigationDecorator < Draper::Decorator
  delegate_all

  def title_link
    h.link_to model.title, h.admin_litigation_path(model)
  end

  def document_type
    model.document_type&.humanize
  end

  def summary
    model.summary&.html_safe
  end

  def at_issue
    model.at_issue&.html_safe
  end

  def document_links
    return [] if model.documents.empty?

    model.documents.map do |document|
      h.link_to document.name,
                document.url,
                target: '_blank',
                title: document.external? ? document.url : nil
    end
  end

  def legislation_links
    return [] if model.legislations.empty?

    model.legislations.map do |legislation|
      h.link_to legislation_link_label(legislation),
                h.admin_legislation_path(legislation),
                target: '_blank',
                title: legislation.title
    end
  end

  def external_legislation_links
    return [] if model.external_legislations.empty?

    model.external_legislations.map do |legislation|
      h.link_to legislation.name,
                h.admin_external_legislation_path(legislation),
                target: '_blank'
    end
  end

  def legislation_link_label(legislation)
    [
      legislation.archived? ? '[ARCHIVED] ' : nil,
      legislation.title.truncate(120)
    ].join.strip
  end
end
