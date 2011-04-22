function set_players_card(json, open){
  for(var i = 0;i < json.length;i++){
    var player = json[i].player;
    set_player_cards(player.user.name, player.cards, open);
  }
};

function get_player(name){
  var $p = $(".player .player_name span:contains('" + name + "')");
  return $p.parent().parent();
}

function set_game_no(value){
  $("#game_no").text(value);
};

function set_place_player(value){
  $("#place_player").text(value);
};

function set_place_info(value){
  $("#place_info").text(value);
};

function set_place(list){
  var cards = $("#place_cards");
  cards.children().remove();
  $.each(list, function(i){
    cards.append("<li><img src='/images/cards/" + list[i].id + ".png'/></li>");
  });
};

function set_player_cards(name, list, open){
  var player = get_player(name);
  var player_cards = player.children(".player_cards").children("ul");
  player_cards.children().remove();
  $.each(list, function(i){
    if(open){
      player_cards.append("<li><img src='/images/cards/" + list[i].id + ".png'/></li>");
    }else{
      player_cards.append("<li><img src='/images/cards/0.png'/></li>");
    }
  });
};

function set_player_place_cards(name, info, list){
  var player = get_player(name);
  var player_place_cards = player.children(".player_place_cards");
  player_place_cards.children().remove();
  if(info != ""){
    player_place_cards.append("<span>" + info + "</span>");
  }else{
    var cards = $("<ul/>"); 
    $.each(list, function(i){
      cards.append("<li><img src='/images/cards/" + list[i].id + ".png'/></li>");
    });
    player_place_cards.append(cards);
  }
};
