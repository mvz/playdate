class AddForeignKeyIndexes < ActiveRecord::Migration
  def self.up
    add_index :availabilities, :player_id
    add_index :availabilities, :playdate_id
  end

  def self.down
    remove_index :availabilities, :player_id
    remove_index :availabilities, :playdate_id
  end
end
