if(typeof(dd) == 'undefined') { dd = {}; }
if(typeof(dd.place) == 'undefined') { dd.place = {}; }

(function() {
  $.extend({
    "put" : function (url, data, success) {
      var error = function(request, text_status, error_thrown) {
        console.debug("start error");
        console.debug(request);
      }; 
      return $.ajax({
        "url" : url,
        "data" : data,
        "success" : success,
        "type" : "PUT",
        "cache" : false,
        "dataType" : "json",
        "error" : error
      });
    }
  });
  $.ajaxSetup({
    cache: false
  });

  /**
   * @class ShowOption
   */
  dd.place.ShowOption = function() {};
  dd.place.ShowOption.prototype = {
    place_id : 0,
    player_count : 0,
    start_url : null,
    next_turn_url : null,
    info_url : null,
    players_card_url : null,
    graph_url : null
  };

  /**
   * @class Place
   */
  dd.place.Place = (function() {
    var Constr;
    var players = null;

    // private methods
    var get_players = function() {
      players = {};
      $(".player").each(function() {
        players[$(this).find(".player_name span").text().trim()] = $(this);
      });
    };

    var set_place = function () {
      $.getJSON(dd.place.ShowOption.info_url, function(json){
        $("#game_no").text(json.game_no);
        $("#place_info").text(json.place_info);
        set_place_cards(json.cards);
      });
    };

    var set_place_info = function(place_info) {
        $("#place_info").text(place_info);
    };

    var set_players_card = function (reverse_flg) {
      $.getJSON(dd.place.ShowOption.players_card_url, function(json){
        for(var i = 0;i < json.length;i++){
          var player = json[i].player;
          set_player_cards(player.user.name, player.cards, reverse_flg);
        }
      });
    };

    var set_player_cards = function (name, list, open) {
      var $player = players[name];
      var $player_cards = $player.children(".player_cards").children("ul");
      $player_cards.children().remove();
      $.each(list, function(i){
        if(open){
          $player_cards.append("<li><img src='/images/cards/" + list[i].id + ".png'/></li>");
        }else{
          $player_cards.append("<li><img src='/images/cards/0.png'/></li>");
        }
      });
    };

    var set_player_place_cards = function (name, info, list) {
      var $player = players[name];
      var $player_place_cards = $player.children(".player_place_cards");
      if(info != ""){
        if($player_place_cards.text().trim().match(/.*RANK:.*/) == null) {
          $player_place_cards.children().remove();
          $player_place_cards.append("<span>" + info + "</span>");
        }
      }else{
        if($player_place_cards.text().trim().match(/.*RANK:.*/) == null) {
          $player_place_cards.children().remove();
          var $cards = $("<ul/>"); 
          $.each(list, function(i){
            $cards.append("<li><img src='/images/cards/" + list[i].card.id + ".png'/></li>");
          });
          $player_place_cards.append($cards);
        }
      }
    };

    var reset_place_and_player = function () {
      var $cards = $("#place_cards");
      $cards.children().remove();
      $cards.append("<li><span style='line-height:80px;'>RESET</span></li>");
      $(".player").each(function() {
        var name = $(this).find(".player_name span").text().trim()
        un_set_player(name)
        set_player_place_cards(name, "", [])
      });
    };

    var init_place_and_player = function () {
      set_place_cards([]);
      $(".player").each(function() {
        var name = $(this).find(".player_name span").text().trim()
        var $player = players[name];
        var $player_place_cards = $player.children(".player_place_cards");
        un_set_player(name)
        set_player_place_cards(name, "", [])
        $player_place_cards.children().remove();
      });
    };

    var set_place_cards = function (list) {
      var $cards = $("#place_cards");
      $cards.children().remove();
      $.each(list, function(i){
        $cards.append("<li class='thumb'><img src='/images/cards/" + list[i].card.id + ".png'/></li>");
      });
    };

    var set_player = function(name) {
      var $player = players[name];
      $player.addClass("select_player");
    };

    var un_set_player = function(name) {
      var $player = players[name];
      $player.removeClass("select_player");
    };

    var next_turn = function() {
      $.put(dd.place.ShowOption.next_turn_url, {}, function() {});
    };

    /**
     * Constractor
     */
    Constr = function() {
    };

    Constr.prototype = {
      get_players : get_players,
      set_place : set_place,
      set_place_info : set_place_info,
      set_players_card : set_players_card,
      set_player_cards : set_player_cards,
      set_player_place_cards : set_player_place_cards,
      reset_place_and_player : reset_place_and_player,
      init_place_and_player : init_place_and_player,
      set_place_cards : set_place_cards,
      set_player : set_player,
      un_set_player : un_set_player,
      next_turn : next_turn
    };

    return Constr;
  })();

  /**
   * @class Show
   */
  dd.place.Show = (function() {
    var Constr;
    var reverse_flg = false;
    var start_flg = false;
    var manual = true;
    var interval = 0;
    var place = new dd.place.Place();

    // private methods
    var  interval_change_exec = function() {
      var val = $("#interval").val();
      if(val == "manual") {
        manual = true;
      } else {
        var now = $("#manual").attr('disabled');
        manual = false;
        interval = parseInt(val) * 1000;
        $("#manual").attr('disabled', true);
        if(start_flg && now) {
          setTimeout(place.next_turn, interval);
        }
      }
    };

    /**
     * Constractor
     */
    Constr = function() {
      place.get_players();
    };

    // public methods
    Constr.prototype = {
      start : function() {
        $.put(dd.place.ShowOption.start_url, {},
          function(data, text_status) { 
            $("#start").attr('disabled', true);
          });
      },

      is_target : function(json) {
        if(json.place == dd.place.ShowOption.place_id) {
          return true;
        } else {
          return false;
        }
      },

      start_place : function(json) {
        $("#reverse").attr('disabled', false);
        start_flg = true
        interval_change_exec();
        if(!manual) {
          setTimeout(place.next_turn, 1500);
        } else {
          $("#manual").attr('disabled', false);
        }
      },

      start_game : function(json) {
        place.init_place_and_player();
        place.set_place();
        place.set_players_card(reverse_flg);
        if(!manual) {
          setTimeout(place.next_turn, 1500);
        } else {
          $("#manual").attr('disabled', false);
        }
      },

      end_game : function(json) {
        if(!manual) {
          setTimeout(place.next_turn, interval);
        } else {
          $("#manual").attr('disabled', false);
        }
      },

      start_turn : function(json) {
        //place.set_place_cards(json.turn_cards);
        place.set_place_info(json.place_info);
        place.set_player(json.player);
      },

      end_turn : function(json) {
        var info = "";
        if(json.turn_cards.length == 0) {
          info = "PASS";
        } else {
          console.debug(json.turn_cards);
          place.set_place_cards(json.turn_cards);
        }
        place.set_player_place_cards(json.player, info, json.turn_cards);
        place.un_set_player(json.player);
        place.set_players_card(reverse_flg);
        if(json.reset_place) {
          setTimeout(function() {
            place.reset_place_and_player();
            if(!manual) {
              setTimeout(place.next_turn, interval);
            } else {
              $("#manual").attr('disabled', false);
            }
          },500);
        } else {
          if(!manual) {
            setTimeout(place.next_turn, interval);
          } else {
            $("#manual").attr('disabled', false);
          }
        }
      },

      end_player : function(json) {
        place.set_player_place_cards(json.player, "RANK:" + json.rank.rank.rank, []);
      },

      next : function(json) {
        $("#manual").attr('disabled', true);
        place.next_turn();
      },

      interval_change : function() {
        interval_change_exec();
      },

      reverse : function() {
        reverse_flg = !reverse_flg;
        place.set_players_card(reverse_flg);
      }
    };

    return Constr;
  })();
})();
