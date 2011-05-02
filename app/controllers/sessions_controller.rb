class SessionsController < ApplicationController
  def new
  end

  def create
    authenticate!
    flash[:notice] = "You loggined!"
    p = Player.find_by_id(current_user.id)
    send_websocket("login", p["place_id"], p.to_json(
      :include => {:user  => {:only => [:id,:name]}},
      :only => [:id]
    ))
    redirect_to operations_path
  end

  def destroy
    logout
    flash[:notice] = "You logoutted!"
    redirect_to login_path
  end

  def unauthenticated
    flash[:notice] = warden.message
  end
end

