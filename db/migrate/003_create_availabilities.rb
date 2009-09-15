class CreateAvailabilities < ActiveRecord::Migration
  def self.up
    create_table :availabilities do |t|
      t.column :player_id, :int
      t.column :playdate_id, :int
      t.column :status, :int
    end
  end

  def self.down
    drop_table :availabilities
  end
end
