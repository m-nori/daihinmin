class PlaceViewController < ApplicationController

  # GET /places/1/game
  def game
    @place = Place.find(params[:id])
    respond_to do |format|
      format.html # game.html.erb
    end
  end

  # GET /places/1/graph
  def graph
    place = Place.find(params[:id])
    respond_to do |format|
      format.json  { render :json => place.graph.to_json }
    end
  end
end
