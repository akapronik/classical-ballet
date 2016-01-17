# config valid only for current version of Capistrano
lock '3.4.0'

set :username, 'pronik'
set :application, 'ballet-troshchen'
set :repo_url, 'git@github.com:akapronik/ballet-troshchen.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/#{fetch(:username)}/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rails_env, 'production'

namespace :setup do
  desc 'Загрузка конфиг файлов на удаленнный сервер'
  task :upload_config do
    on roles :all do
      execute :mkdir, "-p #{shared_path}"
      ['shared/config', 'shared/run'].each do |f|
        upload!(f, shared_path, recursive: true)
      end
    end
  end
end

namespace :nginx do
  desc 'Создание симлинка в /etc/nginx/conf.d на nginx.conf приложения'
  task :append_config do
    on roles :all do
      sudo :ln, "-fs #{shared_path}/config/nginx.conf /etc/nginx/conf.d/#{fetch(:application)}.conf"
    end
  end
  desc 'Релоад nginx'
  task :reload do
    on roles :all do
      sudo :service, :nginx, :reload
    end
  end
  desc 'Рестарт nginx'
  task :restart do
    on roles :all do
      sudo :service, :nginx, :restart
    end
  end
  after :append_config, :restart
end

set :unicorn_config, "#{shared_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/run/unicorn.pid"

namespace :application do
  desc 'Запуск Unicorn'
  task :start do
    on roles(:app) do
      execute "cd #{release_path} && ~/.rvm/bin/rvm default do bundle exec unicorn_rails -c #{fetch(:unicorn_config)} -E #{fetch(:rails_env)} -D"
    end
  end
  desc 'Завершение Unicorn'
  task :stop do
    on roles(:app) do
      execute "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -9 `cat #{fetch(:unicorn_pid)}`; fi"
    end
  end
end

namespace :deploy do
  after :finishing, 'application:stop'
  after :finishing, 'application:start'
  after :finishing, :cleanup
end
