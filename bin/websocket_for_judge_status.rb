require 'rubygems'
require 'eventmachine'
require 'em-websocket'
# Liste mit allen Clients, die verbunden sind
@clients = {}
Process.daemon 
# EventMachine-Loop starten
EM.run do
    # WebSocket-Server erstellen 
    EM::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |client_websocket|
 
        # ausgelöst, wenn Verbindung zum Client hergestellt
        client_websocket.onopen do
            client_id = client_websocket.object_id
            #puts 'Client ' + client_id.to_s + ' connected'
 
            if !@clients.include? client_id
                @clients[client_id] = client_websocket
            end
        end
 
        # ausgelöst, wenn Nachricht vom Client empfangen
        client_websocket.onmessage do |message|
            client_id = client_websocket.object_id
            #puts 'From Client ' + client_id.to_s + ' received message: ' + message

            @clients.each do |client_id, client_ws|
                client_ws.send(message.to_s)
            end
       end
 
        # ausgelöst, wenn Verbindung zum Client geschlossen
        client_websocket.onclose do
            client_id = client_websocket.object_id
            #puts 'Client ' + client_id.to_s + ' disconnected'
 
            if @clients.include? client_id
                @clients.delete client_id
            end
        end
    end
end
