class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required
    return true if authenticated?
    redirect_to login_path
    false
  end

  def send_websocket(operation, place, json)
    add = ",\"operation\":\"#{operation}\",\"place\":#{place}}"
    param = json.sub(/}$/, add)
    MyWebsocket.call(param)
  end
end
