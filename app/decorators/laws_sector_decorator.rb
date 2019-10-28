class LawsSectorDecorator < Draper::Decorator
  delegate_all

  def subsectors_links
    return [] if model.subsectors.empty?

    model.subsectors.map do |sector|
      h.link_to sector.name,
                h.admin_laws_sector_path(sector),
                target: '_blank',
                title: sector.name
    end
  end
end
