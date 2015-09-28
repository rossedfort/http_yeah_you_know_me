require '/Users/rossedfort/code/mod_1/projects/night_writer/lib/night_write'

# require a webserver named Sinatra
require 'sinatra/base'

class NightWriterServer < Sinatra::Base
  get '/to_braille' do
    "<form action='/to_braille' method='post'>
      <input type='textarea' name='english-message'></input>
      <input type='Submit'></input>
    </form>"
  end

  post '/to_braille' do
    message = params['english-message']
    braille = NightWrite.new.write(message) # <-- change this to look like your night writer code
    "<pre>#{braille}</pre>"
  end
end


# switch this to use your server
use_my_server = false

if use_my_server
  require_relative 'lib/http_yeah_you_know_me' # <-- probably right, but double check it
  server = HttpYeahYouKnowMe.new(9292, NightWriterServer)
  at_exit { server.stop }
  server.start
else
  NightWriterServer.set :port, 9292
  NightWriterServer.run!
end
