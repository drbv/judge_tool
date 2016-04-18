# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'judge-tool'
set :repo_url, 'git@github.com:drbv/judge_tool.git'
set :deploy_to, '/home/judge/'
set :branch, 'master'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'db/judge_tool.sqlite3')

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'tmp/files', 'tmp')
set :unicorn_config_path, "#{shared_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do

  after :publishing, 'unicorn:restart'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
