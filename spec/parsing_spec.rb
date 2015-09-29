require_relative '../lib/http_yeah_you_know_me'
require 'stringio'
require 'minitest/autorun'
require 'pry'

class ParsingTest < Minitest::Test
  def test_it_parses
    client = StringIO.new("POST /to_braille HTTP/1.1\r\n" +
                          "Content-length: 10\r\n" +
                          "\r\n" +
                          "0123456789This shit shouldn't show")
    env_hash = HttpYeahYouKnowMe.parse_request(client)
    assert_equal "0123456789", env_hash['rack.input'].gets
  end
end
