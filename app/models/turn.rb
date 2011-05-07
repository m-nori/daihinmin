class Turn < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :place_cards, :dependent => :destroy
  has_many :turn_cards, :dependent => :destroy
  has_many :cards, :through=>:place_cards
end
