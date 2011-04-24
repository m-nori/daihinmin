class MenusController < ApplicationController
  before_filter :login_required

  def index
    @user = User.find_by_id(current_user.id)
    logger.debug(@user.name)
  end
end
