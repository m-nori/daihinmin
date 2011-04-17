class PlaceCard < ActiveRecord::Base
  belongs_to :turn
  belongs_to :card
end
