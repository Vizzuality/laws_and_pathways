ActiveAdmin.register ExternalLegislation do
  config.batch_actions = false

  menu parent: 'Laws', priority: 5

  permit_params :name, :url, :geography_id
end
