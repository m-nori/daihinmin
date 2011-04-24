class Player < ActiveRecord::Base
  belongs_to :place
  belongs_to :user
  has_many :player_cards, :dependent => :destroy
  has_many :cards, :through=>:player_cards

  def self.authenticate(name, password, place_id)
    return nil if name.blank? || password.blank?
    u = User.find_by_name_and_password(name, password)
    if u
      find_by_user_id_and_place_id(u.id, place_id)
    else
      nil
    end
  end
end
