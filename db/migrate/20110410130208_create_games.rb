class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.references :place
      t.integer :no
      t.integer :status
      t.string :place_info
      t.string :rank

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
