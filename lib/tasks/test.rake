namespace :test do
  desc 'Recreate DB dump used in system tests by running seeds and dumping database'
  task :db_dump do
    abort 'Run db_dump task only in test env! RAILS_ENV=test bin/rails test:db_dump' unless Rails.env.test?

    Rake::Task['db:test:prepare'].invoke
    Rails.application.load_seed
    system "pg_dump -Fc --no-owner --dbname=#{db_name} > #{dump_path}"
    DatabaseCleaner.clean_with(:truncation)
  end

  task :db_load do
    abort 'Run db_load task only in test env! RAILS_ENV=test bin/rails test:db_load' unless Rails.env.test?

    unless File.exist?(dump_path)
      puts "Dump file #{dump_path} does not existing. Invoking db_dump task to create it"
      Rake::Task['test:db_dump'].invoke
    end

    system "pg_restore -j 8 --clean --no-owner --dbname=#{db_name} #{dump_path}"
    ActiveRecord::Migration.check_pending!
  rescue ActiveRecord::PendingMigrationError
    abort 'ERROR: Pending migrations in test db dump. Please recreate db dump for system specs bin/rails test:db_dump'
  end

  private

  def dump_path
    Rails.root.join('db/test-dump.psql').to_path
  end

  def db_name
    "postgresql://#{db_config['username']}:#{db_config['password']}@127.0.0.1:5432/#{db_config['database']}"
  end

  def db_config
    Rails.configuration.database_configuration[Rails.env]
  end
end
