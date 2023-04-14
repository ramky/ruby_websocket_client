require 'websocket-client-simple'
require 'json'
require 'pry'
require 'timeout'
require_relative './rest_call'

#WS_URL='ws://localhost:3000/cable?Authorization'
WS_URL='ws://localhost:3000/cable?Author'
TIMEOUT_SECONDS=300

# We read the author this client wants.
author = ARGV[0][7..]

# We open a RestCall to validate the user
rc = RestCall.new(author)
token = rc.get_token
puts token

# We want to pass token in headers.
headers = { 'Authorization' => token}

#ws = WebSocket::Client::Simple.connect WS_URL + '=' + as.token
# I cannot find the way to read header from server.
#ws = WebSocket::Client::Simple.connect WS_URL + '=' + rand(1).to_s, headers

# Finally, pass token in URL.
ws = WebSocket::Client::Simple.connect WS_URL + '=' + author + '&Authorization=' + token

# Once channel is opened we call to obtain books from an author
#rc.sendClient()


ws.on :message do |msg|
  puts "Event with message: [#{msg.data}]"
  json_message = JSON.parse(msg.data)
  if json_message.key?('message') &&
      json_message['message'].class == Hash &&
      json_message['message'].key?('command') &&
      json_message['message']['command'] == 'close'
    puts "Closing connection"
    exit 1
  else
    if json_message.key?('identifier')
       channel = JSON.parse(json_message['identifier'])
       if channel.key?('channel') && channel['channel'] == 'SyncApiChannel' &&
         json_message.key?('message')
          uuid = json_message['message']
          rc.send(uuid)
       end
    end
  end
end

ws.on :open do
  # Send command to subscribe to ActionCable's specific channel after connect to socket
  data = {channel: 'SyncApiChannel'}.to_json
  msg = {
    command: 'subscribe',
    identifier: data
  }
  ws.send(msg.to_json)
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p "Error occurred: #{e}"
end

# TODO: Don't use timeout gem in production, there are known issues with threads and exception handling - only for demo
# client should set to not more than 3 seconds
status = nil
begin
  status = Timeout::timeout(TIMEOUT_SECONDS) { ws.send STDIN.gets.strip }
rescue => exception
  puts "Timeout [#{TIMEOUT_SECONDS}] exceeded."
  exit 1
end