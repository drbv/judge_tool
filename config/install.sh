apt-get update
apt-get dist-upgrad -qy
adduser ews --disabled-password --gecos GECOS
mkdir /home/ews/.ssh
touch /home/ews/.ssh/authorized_keys
chown -R "ews":"ews" /home/ews/.ssh
echo "ews ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
curl https://gitlab.x-ion.de/sparzentny".keys" > /home/ews/.ssh/authorized_keys
apt-get install -qy mdbtools-dev mdbtools nodejs cifs-utils git nginx

curl https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/init.d/ews_beamer > /etc/init.d/ews_beamer
curl https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/init.d/ews_judge > /etc/init.d/ews_judge
curl https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/init.d/ews_observer > /etc/init.d/ews_observer
curl https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/init.d/ews2 > /etc/init.d/ews2
chmod +x /etc/init.d/ews*

curl https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/nginx_ews > /etc/nginx/sites-available/ews
rm /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/ews /etc/nginx/sites-enabled/
systemctl restart nginx.service

su -l ews
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/ews/.rvm/scripts/rvm
gem install bundler
gem install eventmachine
gem install em-websocket
mkdir shared
mkdir shared/config
touch /home/ews/shared/db/judge_tool.sqlite3
cd shared/config
wget https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/database.yml
wget https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/secrets.yml
wget https://raw.githubusercontent.com/drbv/judge_tool/master/config-files/unicorn.rb
cd
wget https://raw.githubusercontent.com/drbv/judge_tool/master/bin/websocket_for_judge_status.rb
wget https://raw.githubusercontent.com/drbv/judge_tool/master/bin/websocket_for_observer.rb
wget https://raw.githubusercontent.com/drbv/judge_tool/master/bin/ws_for_beamer.rb 
ruby websocket_for_judge_status.rb
ruby websocket_for_observer.rb
ruby ws_for_beamer.rb
echo "secret in .bashprofile is missing"
echo "init scripte müssen überarbeitet werde"
