class CreatePlayerCards < ActiveRecord::Migration
  def self.up
    create_table :player_cards do |t|
      t.references :card
      t.references :player

      t.timestamps
    end
  end

  def self.down
    drop_table :player_cards
  end
end
