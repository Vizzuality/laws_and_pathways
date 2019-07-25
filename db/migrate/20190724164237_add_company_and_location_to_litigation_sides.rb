class AddCompanyAndLocationToLitigationSides < ActiveRecord::Migration[5.2]
  def change
    add_reference :litigation_sides,
                  :connected_entity,
                  polymorphic: true,
                  index: {
                    name: 'index_litigation_sides_connected_entity'
                  }
    # add_reference :litigation_sides, :company, foreign_key: {on_delete: :cascade}, index: true
    # add_reference :litigation_sides, :location, foreign_key: {on_delete: :cascade}, index: true
  end
end
