require 'stringio'
require 'pry'

class HttpYeahYouKnowMe
  attr_reader :port, :app, :server
  def initialize(port, app)
    @port = port
    @app = app
    @server = TCPServer.new(port)
  end

  def start
    # Wait for a request
    until server.closed?
      client = server.accept
      env = self.class.parse_request(client)
      write_response(env, client)
    end
  end

  def self.parse_request(client)
    # Read the request
    # parse first line
    env = {}
    first_line = client.gets.split(' ')

    env['REQUEST_METHOD'] = first_line[0]
    env['PATH_INFO'] = first_line[1]
    env['VERSION'] = first_line[2]
    env
    #parse body
  end

  def write_response(env, client)
    # Write the response
    response = @app.call(env)
    client.print("HTTP/1.1 #{response[0]} \r\n")
    response[1].each do |key, value|
      client.print "#{key}: #{value}\r\n"
    end
    client.print("\r\n")
    client.print response[2][0]
    client.close
  end

  def stop
    # I'm done now, computer ^_^
    server.close_read
    server.close_write
  end
end
