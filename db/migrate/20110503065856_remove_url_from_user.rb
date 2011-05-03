class RemoveUrlFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :url
  end

  def self.down
    add_column :users, :url, :string
  end
end
