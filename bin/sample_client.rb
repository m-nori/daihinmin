$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require File.expand_path('../../config/boot',  __FILE__)
require 'logger'
require 'Mechanize'
require "websocket_client"
require "card_utiles"
require "EventMachine"
require "JSON"

class PlayerAccsesor
  LOGIN_URL = "/login"
  GET_HAND_URL = "/operations/get_hand.json"
  OPERATION_URL = "/operations"

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

  def post_cards(cards)
    page = @agent.get(OPERATION_URL)
    form = page.forms.first
    cards.each_with_index do |card,i|
      form["card_#{i}"] = card_to_string(card)
    end
    form.submit
  end

  private
  def card_to_string(card)
    if card[:joker]
      "joker"
    else
      "#{card[:mark]}-#{card[:number]}"
    end
  end
end

def json_cards_to_hash(cards)
  cards.map{|c| c["card"].inject({}){|r,entry| r.store( entry[0].to_sym, entry[1] );r}}
end

def create_pare(hand)
  list = []
  before_number = 99
  tmp = []
  hand.each do |card|
    if card[:number] != before_number
      tmp = []
      list << tmp
    end
    tmp << card
    before_number = card[:number]
  end
  list
end

def create_yaku(hand)
  yaku = {}
  pares = create_pare(hand)  
  pares.each do |pare|
    next if pare == 1
    yaku[pare.length] = [] unless yaku.key?(pare.length)
    yaku[pare.length] << pare
  end
  yaku[1] = []
  hand.each do |card|
    yaku[1] << [card]
  end
  jokers = hand.find_all{|h| h[:joker] }
  jokers.each do |joker|
    yaku_add = {}
    yaku.each_pair do |key,val|
      yaku_add[key+1] = val.map{|pare| pare + [joker]}
    end
    yaku.update(yaku_add){|k,v1,v2| v1 + v2 }
  end
  p yaku
  yaku
end

def select_cards(target, list, revolution)
  resut = []
  list.each do |cards|
    puts "compare #{target.first}<=>#{cards.first}"
    if CardUtiles.compare_to(target.first, cards.first, revolution) == -1
      puts "OK:#{cards}"
      resut = cards
      break
    end
  end
  resut
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
  yaku = nil
  WebsocketClient.connect("localhost", 8081) do |data|
    begin
      json = JSON.parse(data[0])
    rescue
      puts "not json"
      next
    end
    next if json["place"] != place_id.to_i
    case json["operation"]
    when "start_place"
      player_accsesor = PlayerAccsesor.new("http://localhost:3000", user_name, password, place_id)
    when "end_place"
      exit(0)
    # when "start_game"
      # hand = CardUtiles.sort(hand)
    # when "end_game"
      # hand = nil
      # yaku = nil
    when "start_turn"
      if json["player"] == user_name
        # place_info
        revolution = json["place_info"] == "Revolutio"
        place_cards = json_cards_to_hash(json["place_cards"])
        # init
        put_cards = []
        hand = json_cards_to_hash(player_accsesor.get_hand)
        hand = CardUtiles.sort(hand, revolution)
        yaku = create_yaku(hand)
        # select card
        case place_cards.length
        when 0
          if yaku.length != 0
            put_cards = yaku[yaku.keys.sort.last].first
          else
            put_cards = [hand.first]
          end
        when 1
          put_cards = select_cards(place_cards, yaku[1], revolution)
        else
          if CardUtiles.pare?(place_cards) && yaku.key?(place_cards.length)
            put_cards = select_cards(place_cards, yaku[place_cards.length], revolution)
          end
        end
        player_accsesor.post_cards(put_cards)
      end
    # when "end_turn"
      # hand = json_cards_to_hash(player_accsesor.get_hand)
      # hand = CardUtiles.sort(hand)
    else
      puts json["operation"]
    end
  end
end

