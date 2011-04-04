// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
WS_URL = "ws://localhost:8081";
var MyWebScoket = function(exec){
  // conect start
  this.exec = exec;
  this.ws = null;
};
MyWebScoket.prototype.start = function(){
  this.ws = new WebSocket(WS_URL);
  this.ws.onmessage = function(event) {
    exec(event);
  };
}; 

