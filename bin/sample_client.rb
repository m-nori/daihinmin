$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require File.expand_path('../../config/boot',  __FILE__)
require 'Mechanize'
require "websocket_client"
require "EventMachine"

# const setting
LOGIN_URL = "http://localhost:3000/login"
BASE_URL = "http://localhost:3000/operations"
WS_HOST = "localhost"
WS_PORT = 8081

# argment check
if(ARGV.length != 3)
  $stderr.puts("Usage: ruby lib/sample_client.rb user_name password place_id")
  exit(-1)
end

user_name = ARGV[0]
password = ARGV[1]
place_id = ARGV[2]

# login execute
agent = Mechanize.new
page = agent.get(LOGIN_URL)
form = page.forms.first
form["name"] = user_name
form["password"] = password
form["place_id"] = place_id
form.submit

# move opration page
page = agent.get(BASE_URL)

# start the websocket client
EM.run do
  WebsocketClient.connect(WS_HOST, WS_PORT) do |data|
    puts data
  end
end

