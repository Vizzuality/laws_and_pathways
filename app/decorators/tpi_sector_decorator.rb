class TPISectorDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_tpi_sector_path(model)
  end

  def cp_units_list
    model.cp_units.order('valid_since DESC NULLS LAST').map(&:to_s)
  end
end
