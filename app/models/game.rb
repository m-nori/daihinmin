class Game < ActiveRecord::Base
  belongs_to :place
  has_many :turn, :dependent => :destroy
end
