class Player < ActiveRecord::Base
  belongs_to :place
  belongs_to :user
  has_many :player_cards, :dependent => :destroy
  has_many :cards, :through=>:player_cards
end
