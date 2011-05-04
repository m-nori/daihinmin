class AddPlayerIdToTurns < ActiveRecord::Migration
  def self.up
    add_column :turns, :player_id, :int
  end

  def self.down
    remove_column :turns, :player_id
  end
end
