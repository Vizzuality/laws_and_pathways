# config valid for current version and patch releases of Capistrano
lock "~> 3.12"

set :application, "laws-pathways"
set :repo_url, "https://github.com/Vizzuality/laws_and_pathways.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, '.env', 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/downloads', 'vendor/bundle'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :init_system, :systemd
set :rvm_custom_path, '/usr/share/rvm'

set :nvm_type, :user
set :nvm_node, 'v8.16.2'
set :nvm_map_bins, %w{node npm yarn}

# Temporary workaround for https://github.com/koenpunt/capistrano-nvm/issues/25
namespace :nvm do
  namespace :webpacker do
    task :validate => [:'nvm:map_bins'] do
      on release_roles(fetch(:nvm_roles)) do
        within release_path do
          if !test('node', '--version')
            warn "node is not installed"
            exit 1
          end

          if !test('yarn', '--version')
            warn "yarn is not installed"
            exit 1
          end
        end
      end
    end

    task :wrap => [:'nvm:map_bins'] do
      on roles(:web) do
        SSHKit.config.command_map.prefix['rake'].unshift(nvm_prefix)
      end
    end

    task :unwrap do
      on roles(:web) do
        SSHKit.config.command_map.prefix['rake'].delete(nvm_prefix)
      end
    end

    def nvm_prefix
      fetch(
        :nvm_prefix, -> {
          "#{fetch(:tmp_dir)}/#{fetch(:application)}/nvm-exec.sh"
        }
      )
    end

    after 'nvm:validate', 'nvm:webpacker:validate'
    before 'deploy:assets:precompile', 'nvm:webpacker:wrap'
    after 'deploy:assets:precompile', 'nvm:webpacker:unwrap'
  end
end
