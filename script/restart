#!/bin/bash
cd /home/judge/current
kill `cat /home/judge/shared/tmp/pids/unicorn.pid`
/usr/local/rvm/bin/rvm default do bundle exec unicorn -c /home/judge/shared/config/unicorn.rb -E production -D
