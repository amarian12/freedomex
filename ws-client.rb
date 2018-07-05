require 'rubygems'
require 'websocket-client-simple'
require 'active_support/all'
require 'jwt'

# Create valid JWT
def jwt(email, uid, level, state)
  key     = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV.fetch('JWT_PRIVATE_KEY')))
  payload = {
    iat:   Time.now.to_i,
    exp:   10.minutes.from_now.to_i,
    jti:   SecureRandom.uuid,
    sub:   'session',
    iss:   'barong',
    aud:   ['peatio'],
    email: email,
    uid:   uid,
    level: level,
    state: state
  }
  JWT.encode(payload, key, ENV.fetch('JWT_ALGORITHM'))
end

# Host and port of the websocket server.
host = ENV.fetch('WS_HOST', 'localhost')
port = ENV.fetch('WS_PORT', '8080')
payload = {
  x: 'x', y: 'y', z: 'z',
  email: 'test@gmail.com'
}

# Create websocket connection.
ws = WebSocket::Client::Simple.connect("ws://#{host}:#{port}")

# Called on messaged from websocket server.
ws.on(:message) do |msg|
  puts msg.data
end

# Called if connection to server has been opened.
ws.on(:open) do
  # Authenticate.
  auth = jwt('test@gmail.com', 'test@gmail.com', 3, 'active')
  msg = "{ \"jwt\": \"Bearer #{auth}\"}"

  ws.send msg
end

# Called if connection to server has been closed.
ws.on(:close) do |err|
  p err
  exit 1
end

# Called if any server error occured.
ws.on(:error) do |err|
  p err
end

loop {}