server '35.242.181.47', user: 'ubuntu', roles: %w{web app db}, primary: true
set :ssh_options, forward_agent: true

set :branch, 'master'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/laws-pathways'

# append :linked_files, 'config/secrets/google-credentials-staging.json'
