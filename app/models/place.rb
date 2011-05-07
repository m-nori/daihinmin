class Place < ActiveRecord::Base
  validates :title, :presence => true,
    :length => {:maximum => 20}
  validates :game_count, :presence => true

  has_many :games, :dependent => :destroy
  has_many :players, :dependent => :destroy
  accepts_nested_attributes_for :players, :allow_destroy => true,
    :reject_if => lambda{ |attrs| attrs[:user_id].blank? }

  scope :title_matches, 
    lambda {|q| where 'title like :q', :q => "%#{q}%"}

  def info
    map = {}
    game = Game.where(:place_id => id).order("no desc").limit(1)[0]
    turn = Turn.where(:game_id => game.id).order("no desc").limit(1)[0]
    map[:game_no] = game.no
    map[:place_info] = game.place_info
    if turn
      map[:cards] = turn.cards
    else
      map[:cards] = []
    end
    map
  end

  def info_for_player
    map = {}
    map[:game_count] = game_count
    map[:player_count] = players.length
    list = []
    players.each do |p|
      list << {:name => p.user.name,
               :has_card => p.cards.length}
    end
    map[:player_info] = list
    map
  end
end
