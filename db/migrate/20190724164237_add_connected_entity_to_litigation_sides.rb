class AddConnectedEntityToLitigationSides < ActiveRecord::Migration[5.2]
  def change
    add_reference :litigation_sides,
                  :connected_entity,
                  polymorphic: true,
                  index: {
                    name: 'index_litigation_sides_connected_entity'
                  }
  end
end
