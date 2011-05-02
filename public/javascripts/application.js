if(typeof(dd) == 'undefined') { dd = {}; }
if(typeof(dd.core) == 'undefined') { dd.core = {}; }

(function() {
  /**
   * @class Option
   */
  dd.core.Option = function() {};
  dd.core.Option.ws_url = "ws://localhost:8081";

  /**
   * @class Show
   */
  dd.core.WebSocket = {
    /**
     * WebSocket Start
     * @param executer class
     */
    start : function(executer) {
      var ws = new WebSocket(dd.core.Option.ws_url);
      ws.onmessage = function(event) {
        json = JSON.parse(event.data);
        if(executer.is_target(json)) {
          executer[json.operation](json);
        }
      };
    }
  };

})();

