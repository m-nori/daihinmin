$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require File.expand_path('../../config/boot',  __FILE__)
require 'logger'
require 'Mechanize'
require "websocket_client"
require "EventMachine"
require "JSON"

class PlayerAccsesor
  LOGIN_URL = "/login"
  GET_HAND_URL = "/operations/get_hand.json"

  def initialize(url, user_name, password, place_id)
    @url = url
    @agent = Mechanize.new
    @agent.log = Logger.new($stderr)
    @agent.log.level = Logger::INFO

    # login execute
    page = @agent.get(@url + LOGIN_URL)
    form = page.forms.first
    form["name"] = user_name
    form["password"] = password
    form["place_id"] = place_id
    form.submit
  end

  def get_hand
    json = @agent.get_file(GET_HAND_URL)
    JSON.parse(json)
  end
end

# argment check
if(ARGV.length != 3)
  $stderr.puts("Usage: ruby lib/sample_client.rb user_name password place_id")
  exit(-1)
end

# login exec
user_name = ARGV[0]
password = ARGV[1]
place_id = ARGV[2]

# start the websocket client
EM.run do
  player_accsesor = nil
  hand = nil
  WebsocketClient.connect("localhost", 8081) do |data|
    json = JSON.parse(data[0])
    next if json["place"] != place_id.to_i
    case json["operation"]
    when "start_place"
      player_accsesor = PlayerAccsesor.new("http://localhost:3000", user_name, password, place_id)
    when "start_game"
      hand = player_accsesor.get_hand
      p hand
    else
      puts json["operation"]
    end
  end
end

