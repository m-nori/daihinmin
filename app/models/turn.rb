class Turn < ActiveRecord::Base
  belongs_to :game
  has_many :place_cards, :dependent => :destroy
  has_many :turn_cards, :dependent => :destroy
end
