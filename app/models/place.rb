class Place < ActiveRecord::Base
  has_many :players, :dependent => :destroy

  validates :title, :presence => true,
    :length => {:maximum => 20}

  scope :title_matches, 
    lambda {|q| where 'title like :q', :q => "%#{q}%"}
end
