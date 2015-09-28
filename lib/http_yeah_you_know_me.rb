require 'socket'

class HttpYeahYouKnowMe
  attr_accessor :port, :app, :server
  def initialize(port, app)
    port = 9292
    @app = app
    @server = TCPServer.new(port)
  end

  def start
    # Wait for a request
    until server.closed? do
      client = server.accept
      parse_request(client)
    end
  end

  def parse_request(client)
    # Read the request
    first_line = client.gets.split(" ")
    method = first_line[0]
    path = first_line[1]
    version = first_line[2]
    env = {}
    env["REQUEST_METHOD"] = method
    env["PATH_INFO"] = path
    env["VERSION"] = version
    response(env, client)
  end

  def response(env, client)
    # Write the response
    result = app.call(env)
    client.print("HTTP/1.1 #{result[0]} \r\n")
    result[1].each do |key, value|
      client.print "#{key}: #{value}\r\n"
    end
    client.print("\r\n")
    client.print result[2][0]
    client.close
  end

  def stop
    # I'm done now, computer ^_^
    server.close_read
    server.close_write
  end
end
