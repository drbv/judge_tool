
global_config = YAML.load_file "config/global.conf"
$websocket_ip = global_config["websocket_ip"]



begin
  $judge_status_bars = WebSocket::Client::Simple.connect "ws://#{$websocket_ip}:8080"
  $observer = WebSocket::Client::Simple.connect "ws://#{$websocket_ip}:8081"
  $beamer = WebSocket::Client::Simple.connect "ws://#{$websocket_ip}:8082"
rescue
end


