class CreateTurns < ActiveRecord::Migration
  def self.up
    create_table :turns do |t|
      t.references :game
      t.integer :no
      t.integer :placer
      t.string :cards

      t.timestamps
    end
  end

  def self.down
    drop_table :turns
  end
end
