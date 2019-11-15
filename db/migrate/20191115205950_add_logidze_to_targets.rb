class AddLogidzeToTargets < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up
    
    add_column :targets, :log_data, :jsonb
    

    execute <<-SQL
      CREATE TRIGGER logidze_on_targets
      BEFORE UPDATE OR INSERT ON targets FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(null, 'updated_at');
    SQL

    
  end

  def down
    
    execute "DROP TRIGGER IF EXISTS logidze_on_targets on targets;"

    
    remove_column :targets, :log_data
    
    
  end
end
