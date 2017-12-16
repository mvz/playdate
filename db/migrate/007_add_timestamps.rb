class AddTimestamps < ActiveRecord::Migration[5.1]
  def change
    add_column :availabilities, :created_at, :timestamp
    add_column :playdates, :created_at, :timestamp
    add_column :playdates, :updated_at, :timestamp
    add_column :players, :created_at, :timestamp
    add_column :players, :updated_at, :timestamp
  end
end
