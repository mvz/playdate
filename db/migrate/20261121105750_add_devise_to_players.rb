# frozen_string_literal: true

class AddDeviseToPlayers < ActiveRecord::Migration[8.1]
  def change
    change_table :players do |t|
      ## Database authenticatable
      # NOTE: We're not setting null: false on email yet since not all players
      # will have an email to start with.
      t.string :email
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
    end

    add_index :players, :email, unique: true
    add_index :players, :reset_password_token, unique: true
  end
end
