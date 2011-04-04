class Player < ActiveRecord::Base
  belongs_to :place

  validates :name, :presence => true
  validates :url, :presence => true
end
