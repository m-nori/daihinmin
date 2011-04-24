class User < ActiveRecord::Base
  validates :name, :presence => true
  validates :password, :presence => true
  validates :url, :presence => true

  def self.authenticate(name, password)
    return nil if name.blank? || password.blank?
    find_by_name_and_password(name, password)
  end
end
