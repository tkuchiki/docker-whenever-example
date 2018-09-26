# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "docker-whenever-example"
set :repo_url, "git@github.com:tkuchiki/docker-whenever-example.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/app/whenever"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

SSHKit::Backend::Netssh.configure do |ssh|
  ssh.connection_timeout = 30
  ssh.ssh_options = {
    port: 8022,
    keys: "./ssh/id_rsa",
    verify_host_key: :never,
  }
end

set :job_template, "app bash -l -c ':job'"
set :whenever_command,      ->{ [:bundle, :exec, :whenever, "|", "sudo", "tee", "/etc/cron.d/whenever"] }

namespace :deploy do
  after :publishing, :whenever

  task :whenever do
    on roles(:batch), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, "exec", "whenever", "--set environment=#{fetch(:stage)}&job_templae=app bash -l -c :job", "|", "sudo", "tee", "/etc/cron.d/whenever"
      end
    end
  end
end
