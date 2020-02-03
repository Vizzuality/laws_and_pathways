class TPISectorClusterDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_tpi_sector_cluster_path(model)
  end

  def sector_list
    return [] if model.sectors.empty?

    model.sectors.map do |sector|
      h.link_to sector.name, h.admin_tpi_sector_path(sector)
    end
  end
end
