if(typeof(dd) == 'undefined') { dd = {}; }
if(typeof(dd.place) == 'undefined') { dd.place = {}; }

(function() {
  /**
   * @class ShowOption
   */
  dd.place.ShowOption = function() {};
  dd.place.ShowOption.prototype = {
    /**
     * @type String
     */
    start_url : null,
    /**
     * @type String
     */
    open_url : null
  };

  /**
   * @class Show
   */
  dd.place.Show = (function() {
    var Constr;
    var players = null;
    var open_flg = false;

    // private methods
    var get_players = function() {
      players = {};
      $(".player").each(function() {
        players[$(this).find(".player_name span").text().trim()] = $(this);
      });
    };

    var set_players_card = function (json, open) {
      for(var i = 0;i < json.length;i++){
        var player = json[i].player;
        set_player_cards(player.user.name, player.cards, open);
      }
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

    // Constractor
    Constr = function(id) {
      this.id = id;
      get_players();
    }

    // public methods
    Constr.prototype = {
      start : function() {
        $.getJSON(dd.place.ShowOption.start_url, function(json){
          set_players_card(json, open_flg);
        });
      },

      open : function() {
        open_flg = !open_flg
        $.getJSON(dd.place.ShowOption.open_url, function(json){
          set_players_card(json, open_flg);
        });
      }
    };

    return Constr;
  })();

  function set_game_no(value){
    $("#game_no").text(value);
  };

  function set_place_player(name){
    var $player = get_player(name);
  };

  function set_place_info(value){
    $("#place_info").text(value);
  };

  function set_place(list){
    var $cards = $("#place_cards");
    $cards.children().remove();
    $.each(list, function(i){
      $cards.append("<li><img src='/images/cards/" + list[i].id + ".png'/></li>");
    });
  };

  function set_player_place_cards(name, info, list){
    var $player = get_player(name);
    var $player_place_cards = $player.children(".player_place_cards");
    $player_place_cards.children().remove();
    if(info != ""){
      $player_place_cards.append("<span>" + info + "</span>");
    }else{
      var $cards = $("<ul/>"); 
      $.each(list, function(i){
        $cards.append("<li><img src='/images/cards/" + list[i].id + ".png'/></li>");
      });
      $player_place_cards.append($cards);
    }
  };
})();
