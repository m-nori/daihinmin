class RemoveRankFromGames < ActiveRecord::Migration
  def self.up
    remove_column :games, :rank
  end

  def self.down
    add_column :games, :rank, :string
  end
end
