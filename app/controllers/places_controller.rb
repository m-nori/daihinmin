class PlacesController < ApplicationController
  # GET /places
  # GET /places.xml
  def index
    @search_form = SearchForm.new params[:search_form]
    @places = Place.scoped
    if @search_form.q.present?
      @places = @places.title_matches @search_form.q
    end
  end

  # GET /places/1
  # GET /places/1.xml
  def show
    @place = Place.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/new
  # GET /places/new.xml
  def new
    @place = Place.new
    5.times do
      @place.players.build
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/1/edit
  def edit
    @place = Place.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # POST /places
  # POST /places.xml
  def create
    @place = Place.new(params[:place])

    respond_to do |format|
      if @place.save
        format.html { redirect_to(@place, :notice => 'Place was successfully created.') }
        format.xml  { render :xml => @place, :status => :created, :location => @place }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.xml
  def update
    @place = Place.find(params[:id])

    respond_to do |format|
      if @place.update_attributes(params[:place])
        format.html { redirect_to(@place, :notice => 'Place was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.xml
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    respond_to do |format|
      format.html { redirect_to(places_url) }
      format.xml  { head :ok }
    end
  end

  def start
    @place = Place.find(params[:id])
    hands = CardUtiles.create_hand(@place.players.length)
    @place.players.each_with_index do |player, i|
      player.cards = hands[i]
      player.save
    end

    respond_to do |format|
      format.json  { render :json => 
        @place.players.to_json(
          :include => {:cards => {:only => [:id,:joker,:mark,:number]},
            :user  => {:only => [:id,:name]}},
          :only => [:id]
        )
      }
    end
  end

  def open
    @place = Place.find(params[:id])
    respond_to do |format|
      format.json  { render :json => 
        @place.players.to_json(
          :include => {:cards => {:only => [:id,:joker,:mark,:number]},
            :user  => {:only => [:id,:name]}},
          :only => [:id]
        )
      }
    end
  end
end
