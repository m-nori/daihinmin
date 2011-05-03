class AddGameCountFromPlace < ActiveRecord::Migration
  def self.up
    add_column :places, :game_count, :int
  end

  def self.down
    remove_column :places, :game_count
  end
end
