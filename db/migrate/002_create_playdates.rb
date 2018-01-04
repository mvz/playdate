# frozen_string_literal: true

class CreatePlaydates < ActiveRecord::Migration
  def self.up
    create_table :playdates do |t|
      t.column :day, :date
    end
  end

  def self.down
    drop_table :playdates
  end
end
