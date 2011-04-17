class CreateTurnCards < ActiveRecord::Migration
  def self.up
    create_table :turn_cards do |t|
      t.references :turn
      t.references :card

      t.timestamps
    end
  end

  def self.down
    drop_table :turn_cards
  end
end
