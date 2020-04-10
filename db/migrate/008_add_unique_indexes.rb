# frozen_string_literal: true

class AddUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :availabilities, [:player_id, :playdate_id], unique: true
    add_index :playdates, :day, unique: true
    add_index :players, :name, unique: true
  end
end
