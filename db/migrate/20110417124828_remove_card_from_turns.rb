class RemoveCardFromTurns < ActiveRecord::Migration
  def self.up
    remove_column :turns, :placer
    remove_column :turns, :cards
  end

  def self.down
    add_column :turns, :cards, :string
    add_column :turns, :placer, :integer
  end
end
