class AddLogidzeToLegislations < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up
    
    add_column :legislations, :log_data, :jsonb
    

    execute <<-SQL
      CREATE TRIGGER logidze_on_legislations
      BEFORE UPDATE OR INSERT ON legislations FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(null, 'updated_at');
    SQL

    
  end

  def down
    
    execute "DROP TRIGGER IF EXISTS logidze_on_legislations on legislations;"

    
    remove_column :legislations, :log_data
    
    
  end
end
