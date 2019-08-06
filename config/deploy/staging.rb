server '35.242.181.47', user: 'ubuntu', roles: %w{web app db}, primary: true
set :ssh_options, forward_agent: true

set :branch, 'develop'

append :linked_files, 'config/secrets/google-credentials-staging.json'
