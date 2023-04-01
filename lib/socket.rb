require 'websocket-client-simple'
require 'json'

WS_URL='ws://localhost:3000/cable?book_id=1'

ws = WebSocket::Client::Simple.connect WS_URL

ws.on :message do |msg|
  puts msg.data
end

ws.on :open do
  # Send command to subscribe to ActionCable's specific channel after connect to socket
  data = {channel: 'SyncApiChannel'}.to_json
  msg = {
    command: 'subscribe',
    identifier: data
  };
  ws.send(msg.to_json);
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p "Error occurred: #{e}"
end

loop do
  ws.send STDIN.gets.strip
end