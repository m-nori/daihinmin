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
    var reverse_flg = false;
    var login_count = 0;

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
      $player_place_cards.children().remove();
      if(info != ""){
        $player_place_cards.append("<span>" + info + "</span>");
      }else{
        var $cards = $("<ul/>"); 
        $.each(list, function(i){
          $cards.append("<li><img src='/images/cards/" + list[i].card.id + ".png'/></li>");
        });
        $player_place_cards.append($cards);
      }
    };

    var set_place_cards = function (list) {
      var $cards = $("#place_cards");
      $cards.children().remove();
      $.each(list, function(i){
        $cards.append("<li><img src='/images/cards/" + list[i].card.id + ".png'/></li>");
      });
    };

    var set_player = function(name) {
      var $player = players[name];
      $player.find(".player_name").css("background-color", "black").css("color", "#fff");
    };

    var un_set_player = function(name) {
      var $player = players[name];
      $player.find(".player_name").css("background-color", "#fff").css("color", "black");
    };

    var next_turn = function() {
      $.put(dd.place.ShowOption.next_turn_url, {}, function() {});
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
        $("#reverse").attr('disabled', false);
      },

      start_game : function(json) {
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
        next_turn();
      },

      end_player : function(json) {
        set_player_place_cards(json.player, json.rank.rank.rank, []);
      },

      reverse : function() {
        reverse_flg = !reverse_flg;
        set_players_card();
      }
    };

    return Constr;
  })();
})();
