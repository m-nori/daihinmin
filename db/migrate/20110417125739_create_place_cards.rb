class CreatePlaceCards < ActiveRecord::Migration
  def self.up
    create_table :place_cards do |t|
      t.references :turn
      t.references :card

      t.timestamps
    end
  end

  def self.down
    drop_table :place_cards
  end
end
