class PlayersController < ApplicationController
  def create
    place = Place.find params[:place_id]
    place.players.create params[:player]
    redirect_to place
  end

  def destroy
    player = Player.find(params[:id])
    player.destroy
    place = Place.find params[:place_id]

    respond_to do |format|
      format.html { redirect_to(place) }
      format.xml  { head :ok }
    end
  end
end
