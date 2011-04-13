class RemoveNameFromPlayer < ActiveRecord::Migration
  def self.up
    remove_column :players, :name
  end

  def self.down
    add_column :players, :name, :string
  end
end
