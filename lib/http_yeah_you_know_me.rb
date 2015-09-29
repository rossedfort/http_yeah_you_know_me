require 'stringio'
require 'socket'
require 'pry'

class HttpYeahYouKnowMe
  attr_reader :port, :app, :server
  def initialize(port, app)
    @port = port
    @app = app
    @server = TCPServer.new(port)
  end

  def start
    until server.closed?
      client = server.accept
      env = self.class.parse_request(client)
      write_response(env, client)
    end
  end

  def self.parse_request(client)
    env = {}
    first_line = client.gets.split(' ')

    env['REQUEST_METHOD'] = first_line[0]
    env['PATH_INFO'] = first_line[1]
    env['VERSION'] = first_line[2]

    loop do
      next_line = client.gets
      break if next_line == "\r\n"
      env[next_line.split(': ')[0]] = next_line.split(': ')[1].chomp
    end

    content_length = env['Content-length'].to_i
    body = client.read(content_length)
    env['rack.input'] = StringIO.new(body)
    env
  end

  def write_response(env, client)
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
    server.close_read
    server.close_write
  end
end
