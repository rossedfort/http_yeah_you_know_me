require_relative '../lib/http_yeah_you_know_me'
require 'stringio'
require 'minitest/autorun'
require 'pry'

class ParsingUnitTest < Minitest::Test
  def test_parses_the_first_line
    client = StringIO.new("POST /to_braille HTTP/1.1\r\n" +
                       "Content-length: 10\r\n" +
                       "\r\n" +
                       "body")

    env = HttpYeahYouKnowMe.parse_request(client)
    assert_equal "HTTP/1.1", env['VERSION']
    assert_equal "/to_braille", env['PATH_INFO']
    assert_equal "POST", env['REQUEST_METHOD']
  end

  def test_it_parses_no_nore_than_it_needs_to
    client = StringIO.new("POST /to_braille HTTP/1.1\r\n" +
                          "Content-length: 10\r\n" +
                          "\r\n" +
                          "0123456789This shit shouldn't show")
    env = HttpYeahYouKnowMe.parse_request(client)
    assert_equal "0123456789", env['rack.input'].gets
  end
end
