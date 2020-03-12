class ExternalLegislationDecorator < Draper::Decorator
  delegate_all

  def name_summary_link
    h.link_to model.name, h.admin_external_legislation_path(model)
  end

  def as_json(_ = {})
    super(methods: :display_name)
  end
end
