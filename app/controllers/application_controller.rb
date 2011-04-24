class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required
    return true if authenticated?
    redirect_to :controller => "sessions", :action => "new"
    false
  end
end
