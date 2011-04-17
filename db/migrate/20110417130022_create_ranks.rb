class CreateRanks < ActiveRecord::Migration
  def self.up
    create_table :ranks do |t|
      t.references :game
      t.references :player
      t.integer :rank

      t.timestamps
    end
  end

  def self.down
    drop_table :ranks
  end
end
