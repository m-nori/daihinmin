class OperationsController < ApplicationController
  before_filter :login_required

  def index
    @player = Player.find_by_id(current_user.id)
  end

  def get_hand
    p = Player.find_by_id(current_user.id)
    respond_to do |format|
      format.json  { render :json => 
        p.cards.to_json(
          :only => [:id,:joker,:mark,:number]
        )
      }
      format.xml  { render :json => 
        p.cards.to_xml(
          :only => [:id,:joker,:mark,:number]
        )
      }
    end
  end

  def get_place_info
    p = Player.find_by_id(current_user.id)
    place = Place.find(p.place_id)
    respond_to do |format|
      format.json  { render :json => place.info_for_player.to_json }
      format.xml  { render :json => place.info_for_player.to_xml }
    end
  end
end
