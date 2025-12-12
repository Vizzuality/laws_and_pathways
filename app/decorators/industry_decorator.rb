class IndustryDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_industry_path(model)
  end

  def sector_list
    return [] if model.tpi_sectors.empty?

    model.tpi_sectors.order(:name).map do |sector|
      h.link_to sector.name, h.admin_tpi_sector_path(sector)
    end
  end
end
