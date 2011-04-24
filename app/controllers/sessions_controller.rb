class SessionsController < ApplicationController
  def new
  end

  def create
    authenticate!
    flash[:notice] = "You loggined!"
    redirect_to :controller => "menus", :action => "index"
  end

  def destroy
    logout
    flash[:notice] = "You logoutted!"
    redirect_to login_path
  end

  def unauthenticated
    flash[:notice] = warden.message
    redirect_to login_path
  end
end

