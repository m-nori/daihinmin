class Place < ActiveRecord::Base
  validates :title, :presence => true,
    :length => {:maximum => 20}

  has_many :players, :dependent => :destroy
  accepts_nested_attributes_for :players, :allow_destroy => true,
    :reject_if => lambda{ |attrs| attrs[:user_id].blank? }

  scope :title_matches, 
    lambda {|q| where 'title like :q', :q => "%#{q}%"}
end
