set :branch, ask('branch to deploy ( default master )', 'master', echo: true)
set :server_ip, ask('Give the server ip', nil, echo: true)
set :user, ask('user ( default judge )', 'judge', echo: true)
server fetch(:server_ip),user: fetch(:user), roles: %{web app db}
