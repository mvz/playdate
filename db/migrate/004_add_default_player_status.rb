# frozen_string_literal: true

class AddDefaultPlayerStatus < ActiveRecord::Migration
  def self.up
    add_column :players, :default_status, :integer
  end

  def self.down
    remove_column :players, :default_status
  end
end
