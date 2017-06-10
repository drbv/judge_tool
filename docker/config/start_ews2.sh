#!/bin/bash
nginx
cd /root
ruby bin/websocket_for_observer.rb
ruby bin/websocket_for_judge_status.rb
ruby bin/ws_for_beamer.rb
rm tmp/pids/unicorn.pid
unicorn -c /root/config/unicorn.rb -E production 
