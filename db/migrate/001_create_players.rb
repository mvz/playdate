# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.column :name, :string
      t.column :full_name, :string
      t.column :abbreviation, :string
      t.column :password_hash, :string
      t.column :password_salt, :string

      # NOTE: This offense is fixed in the FixThreeStateIsAdmin migration
      # rubocop:disable Rails/ThreeStateBooleanColumn
      t.column :is_admin, :boolean
      # rubocop:enable Rails/ThreeStateBooleanColumn
    end
  end

  def self.down
    drop_table :players
  end
end
