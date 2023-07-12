server '35.242.181.47', user: 'ubuntu', roles: %w{web app db}, primary: true
set :ssh_options, forward_agent: true

set :branch, 'master'

set :deploy_to, '/var/www/laws-pathways-production'

append :linked_files, 'config/secrets/google-credentials-staging.json'

set :rvm_ruby_version, '2.7.8'
