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
      @game_count = 0
      init_game
      send_websocket("start_place", @place.to_json)
    end

    def next_turn
      last = false
      case
      when @game == nil
        if @game_count < @place.game_count
          # new game start
          start_game
        else
          # end place
          last = true
          send_websocket("end_place", @place.to_json)
        end
      when game_end?
        # end game
        init_game
      else
        # start next turn
        start_turn 
      end
      !last
    end

    private
    def init_game
        @game = nil
        @game_place = []
        @game_players = []
        @turn_player_index = 0
        @turn_count = 0
    end

    def start_game
      @game_count += 1
      @game = @place.games.build(:no => @game_count,
                                 :status => 0,
                                 :place_info => "Nomal")
      @game.save
      create_players_hand
      @game_players = create_player_list
      send_websocket("start_game", @game.to_json)
    end

    def game_end?
      @game_players.length == 1 ? true : false
    end

    def start_turn
      @turn = nil
      @turn_count += 1
      turn_player = @game_players[@turn_player_index]
      @turn = Turn.new(:game_id => @game.id,
                       :player_id => turn_player.id,
                       :no => @turn_count)
      @turn.place_cards = @game_place
      @turn.save
      send_data = {:player => turn_player.user.name, 
                   :place_cards => @game_place,
                   :place_info => @game.place_info}
      send_websocket("start_turn", send_data.to_json)
    end

    def end_turn
      # TODO etc...
      @turn_player_index = next_player
    end

    def create_players_hand
      hands = CardUtiles.create_hand(@place.players.length)
      # TODO card change
      @place.players.each_with_index do |player, i|
        player.cards = hands[i]
        player.save
      end
    end

    def create_player_list
      list = []
      players = @place.players
      if @game_count == 1
        start_player = (Player.joins(:cards).where(:place_id => @place.id) &
                        Card.where(:mark => 2).where(:number => 3))[0]
      else
        # TODO from rank
        start_player = players[0]
      end
      i = players.index(start_player)
      m = players.length
      if i == 0
        list = players
      else
        list = players[i..(m-1)] + players[0..(i-1)]
      end
      list
    end

    def next_player
      index = @turn_player_index + 1
      index = 0 if @game_players.length  <= index
      index
    end

    def send_websocket(operation, json)
      add = ",\"operation\":\"#{operation}\",\"place\":#{@place.id}}"
      param = json.sub(/}$/, add)
      WebsocketSender.call(param)
    end
  end
end
