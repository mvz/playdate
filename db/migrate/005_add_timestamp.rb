class AddTimestamp < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :updated_at, :timestamp
  end

  def self.down
    remove_column :availabilities, :updated_at
  end
end
