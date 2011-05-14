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
    players_card_url : null
  };

  /**
   * @class Show
   */
  dd.place.Show = (function() {
    var Constr;
    var players = null;
    var start_flg = false;
    var reverse_flg = false;
    var manual = true;
    var interval = 0;

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

    var set_players_card = function () {
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
      set_place_cards([]);
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

    var  interval_change_exec = function() {
      var val = $("#interval").val();
      if(val == "manual") {
        manual = true;
        if(start_flg) {
          $("#manual").attr('disabled', false);
        }
      } else {
        manual = false;
        interval = parseInt(val) * 1000;
        $("#manual").attr('disabled', true);
      }
    };

    /**
     * Constractor
     */
    Constr = function() {
      get_players();
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
        start_flg = true;
        $("#reverse").attr('disabled', false);
        interval_change_exec();
      },

      start_game : function(json) {
        init_place_and_player();
        set_place();
        set_players_card();
        next_turn();
      },

      end_game : function(json) {
        next_turn();
      },

      start_turn : function(json) {
        set_place();
        set_player(json.player);
      },

      end_turn : function(json) {
        var info = "";
        if(json.turn_cards.length == 0) {
          info = "PASS";
        }
        set_player_place_cards(json.player, info, json.turn_cards);
        un_set_player(json.player);
        set_players_card();
        if(json.reset_place) {
          reset_place_and_player();
        }
        if(!manual) {
          setTimeout(next_turn, interval);
        }
      },

      end_player : function(json) {
        set_player_place_cards(json.player, "RANK:" + json.rank.rank.rank, []);
      },

      next : function(json) {
        next_turn();
      },

      interval_change : function() {
        interval_change_exec();
      },

      reverse : function() {
        reverse_flg = !reverse_flg;
        set_players_card();
      }
    };

    return Constr;
  })();
})();
