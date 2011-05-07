class PlaceListener
  @@hash = {}
  @@logger = nil

  def self.start(id, place, logger=nil)
    core = PlaceListenerCore.new(place, logger)
    @@logger ||= logger
    @@hash[id.to_s] = core
    # Thread.new do
      core.start
      core.next_turn
    # end
  end

  def self.next_turn(id)
    core = @@hash[id.to_s]
    if core
      # Thread.new do
        core.next_turn
      # end
    end
  end

  def self.accept_cards(id, player_id, card_strings)
    core = @@hash[id.to_s]
    if core
      # Thread.new do
        core.accept_cards(player_id, card_strings)
      # end
    end
  end

  private
  def self.debug(msg)
    if @@logger
      @@logger.debug(msg)
    end
  end

  class PlaceListenerCore
    def initialize(place, logger)
      @place = place
      @logger = logger
    end

    def start
      debug("start")
      Game.where(:place_id => @place.id).each do |g|
        Game.delete(g.id)
      end
      @game_count = 0
      init_game
      send_websocket("start_place", @place.to_json)
    end

    def next_turn
      debug("next_turn")
      case
      when @game == nil
        if @game_count < @place.game_count
          start_game
        else
          end_place
        end
      when @game_players.length == 1 ? true : false
        end_game
      else
        start_turn 
      end
    end

    def accept_cards(player_id, card_strings)
      debug("accept_cards")
      # TODO time out
      cards = CardUtiles.to_hashs(card_strings)
      if put_place?(player_id, cards)
        update_turn(cards)
        end_player(@turn.player) if @turn.player.cards.length == 0
        case
        when @pass_players.length == (@game_players.length - 1)
          @turn_player_index = next_player(@turn_player_index)
          reset_place
        when @game_place.any?{|card| card[:number] == 8}
          reset_place
        else
          @turn_player_index = next_player(@turn_player_index)
        end
      else
        miss_end_player(@turn.player)
        reset_place
      end
      end_turn
    end

    private
    def end_place
      debug("end_place")
      send_websocket("end_place", @place.to_json)
    end

    def init_game
      debug("init_game")
      @game = nil
      @game_place = []
      @game_players = []
      @turn_player_index = 0
      @turn_count = 0
      @revolution = false
      @pass_players = []
      @ranks = Array.new(@place.players.length)
    end

    def start_game
      debug("start_game")
      @game_count += 1
      @game = @place.games.build(:no => @game_count,
                                 :status => 0,
                                 :place_info => get_place_info)
      @game.save
      create_players_hand
      @game_players = create_player_list
      send_websocket("start_game", @game.to_json)
    end

    def end_game
      debug("end_game")
      end_player(@game_players[0])
      @game.status = 1
      @game.ranks  = @ranks
      @game.save
      send_websocket("end_game", @game.to_json)
      init_game
    end

    def start_turn
      debug("start_turn")
      @turn = nil
      @put_cards = []
      @turn_count += 1
      turn_player = @game_players[@turn_player_index]
      @turn = Turn.new(:game_id => @game.id,
                       :player_id => turn_player.id,
                       :no => @turn_count)
      @turn.place_cards = @game_place.map{|c| p=PlaceCard.new; p.card = c; p}
      @turn.save
      send_data = {:player => turn_player.user.name, 
                   :place_cards => @game_place,
                   :place_info => @game.place_info}
      send_websocket("start_turn", send_data.to_json)
    end

    def update_turn(cards)
      debug("update_turn")
      player = @turn.player
      player_cards = CardUtiles.reject(player.cards, cards)
      @put_cards = CardUtiles.find_all(player.cards, cards)
      @turn.turn_cards = @put_cards.map{|c| t=TurnCard.new; t.card = c; t}
      @turn.save
      player.cards = player_cards
      player.save
      if cards.length != 0
        @game_place = @put_cards
      else
        @pass_players << player.id
      end
    end

    def end_turn
      debug("end_turn")
      send_data = {:player => @turn.player.user.name, 
                   :turn_cards => @put_cards}
      send_websocket("end_turn", send_data.to_json)
    end

    def reset_place
      debug("reset_place")
      # set revolution
      if @game_place.length >= 4 && CardUtiles.pare?(@game_place)
        @revolution = !@revolution
      end
      # reset place
      @game_place = []
      @pass_players = []
      send_websocket("reset_place", {}.to_json)
    end

    def put_place?(player_id, cards)
      debug("put_place?")
      debug(cards)
      case
      when @turn == nil
        debug("turn nil")
        false
      when @turn.player.id != player_id
        debug("plyayer id not match")
        false
      when !CardUtiles.include?(@turn.player.cards, cards)
        debug("plyayer cards not include")
        false
      when !CardUtiles.yaku?(cards)
        debug("yaku miss")
        false
      when !CardUtiles.compare_yaku(@game_place, cards, @revolution)
        debug("yaku loss")
        false
      else
        true
      end
    end

    def end_player(player)
      debug("end_player")
      rank = nil
      @ranks.length.times do |i|
        unless @ranks[i-1]
          rank = Rank.new(:rank => i)
          rank.game = @game
          rank.player = player
          @ranks[i-1] = rank
          break
        end
      end
      @game_players = @game_players.reject{|p| p == player}
      send_data = {:player => player.user.name,
                   :rank => rank}
      send_websocket("end_player", send_data.to_json)
    end

    def miss_end_player(player)
      debug("miss_end_player")
      rank = nil
      @ranks.length.downto(1) do |i|
        unless @ranks[i-1]
          rank = Rank.new(:rank => i)
          rank.game = @game
          rank.player = player
          @ranks[i-1] = rank
          break
        end
      end
      @game_players = @game_players.reject{|p| p == player}
      player.cards = []
      player.save
      send_data = {:player => player.user.name,
                   :rank => rank}
      send_websocket("end_player", send_data.to_json)
    end

    def create_players_hand
      debug("create_players_hand")
      hands = CardUtiles.create_hand(@place.players.length)
      # TODO card change
      @place.players.each_with_index do |player, i|
        player.cards = hands[i]
        player.save
      end
    end

    def create_player_list
      debug("create_player_list")
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

    def next_player(now_index)
      debug("next_player")
      index = now_index + 1
      index = 0 if @game_players.length  <= index
      if @pass_players.include?(@game_players[index].id)
        next_player(index)
      else
        index
      end
    end

    def send_websocket(operation, json)
      debug("send_websocket")
      add = ",\"operation\":\"#{operation}\",\"place\":#{@place.id}}"
      param = json.sub(/}$/, add)
      debug("send_msg=#{param}")
      WebsocketSender.call(param)
    end

    def get_place_info
      if @revolution
        "Revolution"
      else
        "Nomal"
      end
    end

    def debug(msg)
      if @logger
        @logger.debug(msg)
      end
    end
  end
end
