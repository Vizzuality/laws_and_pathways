class AddTsVectorColumns < ActiveRecord::Migration[6.0]
  def up
    add_column :legislations, :tsv, :tsvector
    add_index :legislations, :tsv, using: :gin

    execute <<-SQL
      CREATE FUNCTION legislation_tsv_trigger() RETURNS trigger AS $$
      begin
        new.tsv :=
           setweight(to_tsvector(unaccent(coalesce(new.title,''))), 'A') ||
           setweight(to_tsvector(unaccent(coalesce(new.description,''))), 'B');
        return new;
      end
      $$ LANGUAGE plpgsql;
    SQL
    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON legislations FOR EACH ROW EXECUTE PROCEDURE
      legislation_tsv_trigger()
    SQL
    execute 'UPDATE legislations SET updated_at = updated_at'

    add_column :litigations, :tsv, :tsvector
    add_index :litigations, :tsv, using: :gin

    execute <<-SQL
      CREATE FUNCTION litigation_tsv_trigger() RETURNS trigger AS $$
      begin
        new.tsv :=
           setweight(to_tsvector(unaccent(coalesce(new.title,''))), 'A') ||
           setweight(to_tsvector(unaccent(coalesce(new.summary,''))), 'B');
        return new;
      end
      $$ LANGUAGE plpgsql;
    SQL
    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON litigations FOR EACH ROW EXECUTE PROCEDURE
      litigation_tsv_trigger()
    SQL
    execute 'UPDATE litigations SET updated_at = updated_at'

    add_column :targets, :tsv, :tsvector
    add_index :targets, :tsv, using: :gin

    execute <<-SQL
      CREATE FUNCTION target_tsv_trigger() RETURNS trigger AS $$
      begin
        new.tsv := to_tsvector(unaccent(coalesce(new.description)));
        return new;
      end
      $$ LANGUAGE plpgsql;
    SQL
    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON targets FOR EACH ROW EXECUTE PROCEDURE
      target_tsv_trigger()
    SQL
    execute 'UPDATE targets SET updated_at = updated_at'
  end

  def down
    execute 'DROP TRIGGER tsvectorupdate ON legislations'
    execute 'DROP FUNCTION legislation_tsv_trigger'
    remove_index :legislations, :tsv
    remove_column :legislations, :tsv

    execute 'DROP TRIGGER tsvectorupdate ON litigations'
    execute 'DROP FUNCTION litigation_tsv_trigger'
    remove_index :litigations, :tsv
    remove_column :litigations, :tsv

    execute 'DROP TRIGGER tsvectorupdate ON targets'
    execute 'DROP FUNCTION target_tsv_trigger'
    remove_index :targets, :tsv
    remove_column :targets, :tsv
  end
end
