class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.integer :mark
      t.integer :number
      t.boolean :joker

      t.timestamps
    end
  end

  def self.down
    drop_table :cards
  end
end
