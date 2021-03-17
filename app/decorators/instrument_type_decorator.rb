class InstrumentTypeDecorator < Draper::Decorator
  delegate_all

  def name_link
    h.link_to model.name, h.admin_instrument_type_path(model)
  end

  def instrument_links
    model.instruments.map do |instrument|
      h.link_to instrument.name,
                h.admin_instrument_path(instrument),
                target: '_blank',
                title: instrument.name
    end
  end
end
