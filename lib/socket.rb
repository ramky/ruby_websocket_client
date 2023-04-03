require 'websocket-client-simple'
require 'json'
require 'pry'

WS_URL='ws://localhost:3000/cable?book_id=1'

ws = WebSocket::Client::Simple.connect WS_URL

ws.on :message do |msg|
  puts "Event with message: [#{msg.data}]"
  json_message = JSON.parse(msg.data)
  if json_message.key?('message') &&
      json_message['message'].class == Hash &&
      json_message['message'].key?('command') &&
      json_message['message']['command'] == 'close'
    puts "Closing connection"
    exit 1
  end
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

# TODO: Timeout after 30 seconds (only for demo - client should set to not more than 3 seconds)
loop do
  ws.send STDIN.gets.strip
end