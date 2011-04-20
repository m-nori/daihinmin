$(function(){
  $("#test").click(function(){
    set_place([1,2,3,4]);
    set_player_cards(0,[0,0,0,0,0,0,0,0,0,0]);
    set_player_cards(1,[0,0,0,0,0,0,0,0]);
    set_player_cards(2,[0,0,0,0,0,0,0,0,0,0]);
    set_player_cards(3,[0,0,0,0,0,0,0]);
    set_player_cards(4,[0]);
    set_player_place_cards(0,"",[1,2,3,4]);
    set_player_place_cards(1,"pass",[]);
    set_player_place_cards(2,"rank 1",[]);
    set_player_place_cards(3,"",[1]);
    set_player_place_cards(4,"",[53]);
  });
});

function start(json){
  for(var i = 0;i < json.length;i++){
    alert(json[i].player.user.name);
  }
};

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
    cards.append("<li><img src='/images/cards/" + list[i] + ".png'/></li>");
  });
};

function set_player_cards(id, list){
  var player_cards = $(".player").eq(id).children(".player_cards").children("ul");
  player_cards.children().remove();
  $.each(list, function(i){
    player_cards.append("<li><img src='/images/cards/" + list[i] + ".png'/></li>");
  });
};

function set_player_place_cards(id, info, list){
  var player_place_cards = $(".player").eq(id).children(".player_place_cards");
  player_place_cards.children().remove();
  if(info != ""){
    player_place_cards.append("<span>" + info + "</span>");
  }else{
    var cards = $("<ul/>"); 
    $.each(list, function(i){
      cards.append("<li><img src='/images/cards/" + list[i] + ".png'/></li>");
    });
    player_place_cards.append(cards);
  }
};
