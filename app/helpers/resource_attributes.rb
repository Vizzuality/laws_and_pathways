module ResourceAttributes
  PERMITTED_PARAMS = {
    events: [
      :id, :_destroy, :title, :event_type, :description, :url, :date
    ],
    litigation_sides: [
      :id, :_destroy, :name, :side_type, :party_type, :connected_with
    ],
    documents: [
      :id, :_destroy, :name, :language, :external_url, :type, :file
    ]
  }.freeze

  def permit_params_for(resource_name)
    PERMITTED_PARAMS[resource_name.to_sym]
  end
end
