FROM ruby:2.4.1-slim 

RUN apt-get update && apt-get install -y mdbtools-dev mdbtools nodejs build-essential zlib1g-dev liblzma-dev libsqlite3-dev nginx curl zip 

COPY ./Gemfile* /root/
WORKDIR /root
RUN bundle install

COPY ./app /root/app
COPY ./bin /root/bin
COPY ./lib /root/lib
COPY ./public /root/public
COPY ./config /root/config
COPY ./docker/config/* /root/config/
COPY ./docker/tmp /root/tmp
COPY ./docker/db /root/db
COPY ./db/migrate /root/db/migrate
COPY ./config.ru /root
COPY ./Rakefile /root
RUN mkdir /root/log 
RUN mv /root/config/nginx.conf /etc/nginx/sites-enabled/default
RUN mv /root/config/nginx_server.conf /etc/nginx/nginx.conf
RUN RAILS_ENV=production bundle exec rake db:migrate
RUN RAILS_ENV=production bundle exec rake assets:precompile
RUN apt-get autoremove -y build-essential 
EXPOSE 80 8080 8081 8082
CMD /root/config/start_ews2.sh
