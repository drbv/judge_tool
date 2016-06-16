# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'judge-tool'
set :repo_url, 'git@github.com:drbv/judge_tool.git'
set :deploy_to, ask('deploy driecrory', '/home/ews', echo: true)
set :branch, 'master'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'db/judge_tool.sqlite3')

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'tmp/files', 'tmp')
set :unicorn_config_path, "#{shared_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do

  task :restart do
    invoke 'unicorn:stop'
    on roles(fetch(:unicorn_roles)) do
      200.times do
        break unless test("[ -e #{fetch :unicorn_pid}]")
        sleep 0.1
      end
    end
    invoke 'unicorn:start'
  end  

  after :published, :restart

end
