server '35.242.181.47', user: 'ubuntu', roles: %w{web app db}, primary: true
set :ssh_options, forward_agent: true

set :branch, ENV.fetch('BRANCH') { 'develop' }

set :deploy_to, '/var/www/laws-pathways-staging'

append :linked_files, 'config/secrets/google-credentials-staging.json'

set :rvm_ruby_version, '2.7.5'
