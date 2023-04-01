require 'faye/websocket'
require 'eventmachine'

class Socket
  def self.run
    EM.run {
      ws = Faye::WebSocket::Client.new('ws://localhost:3000/cable?book_id=1')

      ws.on :open do |event|
        p [:open]
        ws.send('Hello, world!')
      end

      ws.on :message do |event|
        p [:message, event.data]
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        ws = nil
      end
    }
  end
end
