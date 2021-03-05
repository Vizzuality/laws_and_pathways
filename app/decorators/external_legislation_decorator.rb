class ExternalLegislationDecorator < Draper::Decorator
  delegate_all

  def name
    model.name.strip
  end

  def name_summary_link
    h.link_to model.name, h.admin_external_legislation_path(model)
  end

  def litigations_links
    return [] if model.litigations.empty?

    model.litigations.map do |litigation|
      h.link_to litigation.title, h.admin_litigation_path(litigation), target: '_blank'
    end
  end

  def as_json(_ = {})
    super(methods: :display_name)
  end
end
