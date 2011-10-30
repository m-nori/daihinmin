if(typeof(dd) == 'undefined') { dd = {}; }
if(typeof(dd.place) == 'undefined') { dd.place = {}; }

(function() {
  /**
   * @class GameView
   */
  dd.place.GameView = (function() {
    var Constr;
    var reverse_flg = false;
    var place = new dd.place.Place();

    var graph_view = function () {
      $.getJSON(dd.place.ShowOption.graph_url, function(json){
        $('#graph').empty();
        $.jqplot(
          'graph', 
          [json],
          {
            title: '得点！',
            series:[{renderer:$.jqplot.BarRenderer}],
            axesDefaults: {
            tickRenderer: $.jqplot.CanvasAxisTickRenderer ,
            tickOptions: {
              angle: 0,
              fontSize: '9pt'
            }
            },
            axes: {
              xaxis: {
              renderer: $.jqplot.CategoryAxisRenderer
              }
            }
        });
      });
    };

    /**
     * Constractor
     */
    Constr = function() {
      graph_view();
      place.get_players();
    };

    // public methods
    Constr.prototype = {
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
        place.init_place_and_player();
        place.set_place();
        place.set_players_card(reverse_flg);
      },

      end_game : function(json) {
        graph_view();
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
          place.set_place_cards(json.turn_cards);
        }
        place.set_player_place_cards(json.player, info, json.turn_cards);
        place.un_set_player(json.player);
        place.set_players_card(reverse_flg);
        if(json.reset_place) {
          setTimeout(function() {
            place.reset_place_and_player();
          },500);
        }
      },

      end_player : function(json) {
        place.set_player_place_cards(json.player, "RANK:" + json.rank.rank.rank, []);
      },

      reverse : function() {
        reverse_flg = !reverse_flg;
        place.set_players_card(reverse_flg);
      }
    };

    return Constr;
  })();
})();
