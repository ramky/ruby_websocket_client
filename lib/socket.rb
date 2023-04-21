require 'websocket-client-simple'
require 'json'
require 'pry'
require 'timeout'
require_relative './rest_call'

WS_URL='ws://localhost:3000/cable?Author'
TIMEOUT_SECONDS=60

# We read the author this client wants.
author = ARGV[0][7..]

# We open a RestCall to validate the user and obtain token. We always use f@tela.com user.
rc = RestCall.new()
token = rc.get_token
puts token

# Test1: We want to pass token in headers.
#headers = { 'Authorization' => token}
# Test1 Results: I cannot find the way to read header from server.
#ws = WebSocket::Client::Simple.connect WS_URL + '=' + author, headers

# Test2: If we try to connect using WSS you have to configurate params to align version's number between server and client.
#wss_options = {:ssl_version => "TLSv1_2"}
#ws = WebSocket::Client::Simple.connect(WS_URL + '=' + author + '&Authorization=' + token, wss_options)
# Test2 results: leave this investigation. We need to provide SSL from server or try to bypass, without success.

# We open websocket and pass token in URL. If token is not correct, websocket won't be opened.
# We pass author id as parameter (we open the websocket to obtain books for this author and when that is done, ws connection will be closed)
ws = WebSocket::Client::Simple.connect(WS_URL + '=' + author + '&Authorization=' + token)

# We process messages received on websocket communication opened.
ws.on :message do |msg|
  puts "Event with message: [#{msg.data}]"
  json_message = JSON.parse(msg.data)
  if json_message.key?('message') &&
      json_message['message'].class == Hash &&
      json_message['message'].key?('command') &&
      json_message['message']['command'] == 'close'
    puts "Closing connection"
    exit 1
  elsif json_message.key?('identifier')
       channel = JSON.parse(json_message['identifier'])
       if channel.key?('channel') && channel['channel'] == 'SyncApiChannel' &&
         json_message.key?('message')
          # This uuid message is sent from synchApiChannel.subscribed
          uuid = json_message['message']
          # Once channel is opened we call to obtain books from an author
          rc.send(uuid)
       end
  elsif json_message.key?('type') && json_message['type'] == 'disconnect' &&
       json_message.key?('reason') && json_message['reason'] == 'unauthorized'
      puts "Closing connection by unauthorized message"
      exit 1
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