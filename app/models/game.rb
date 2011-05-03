class Game < ActiveRecord::Base
  belongs_to :place
  has_many :turns, :dependent => :destroy
  has_many :ranks, :dependent => :destroy
end
