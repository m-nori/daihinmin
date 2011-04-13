class RemoveUrlFromPlayer < ActiveRecord::Migration
  def self.up
    remove_column :players, :url
  end

  def self.down
    add_column :players, :url, :string
  end
end
