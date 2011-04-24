class MenusController < ApplicationController
  before_filter :login_required

  def index
    @Player = Player.find_by_id(current_user.id)
  end
end
