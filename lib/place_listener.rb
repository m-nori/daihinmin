class PlaceListener
  @@map = {}

  def self.add(id, place)
    @@map[id] = PlaceListenerCore.new(place)
  end

  def self.get(id)
    @@map[id]
  end

  class PlaceListenerCore
    def initialize(place)
      @place = place
      @game = nil
      @game_count = 0
      send_websocket("start_place", @place.id, @place.to_json)
    end

    def next_turn
      last = false
      case
      when @game == nil
        if @game_count < @place.game_count
          start_game
        else
          last = true
          send_websocket("end_place", @place.id, @place.to_json)
        end
      end
      !last
    end

    private
    def start_game
      @game_count += 1
      @game = @place.games.build(:no => @game_count,
                                 :status => 0,
                                 :place_info => "")
      @game.save
      hands = CardUtiles.create_hand(@place.players.length)
      @place.players.each_with_index do |player, i|
        player.cards = hands[i]
        player.save
      end
      send_websocket("start_game", @game.place_id, @game.to_json)
    end

    def send_websocket(operation, place, json)
      add = ",\"operation\":\"#{operation}\",\"place\":#{place}}"
      param = json.sub(/}$/, add)
      WebsocketSender.call(param)
    end
  end
end
