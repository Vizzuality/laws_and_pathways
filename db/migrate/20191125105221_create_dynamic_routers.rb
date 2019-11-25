class CreateDynamicRouters < ActiveRecord::Migration[6.0]
  def change
    create_table :dynamic_routers do |t|

      t.timestamps
    end
  end
end
