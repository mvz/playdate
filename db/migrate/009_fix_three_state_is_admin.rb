# frozen_string_literal: true

class FixThreeStateIsAdmin < ActiveRecord::Migration[7.0]
  def change
    change_column_null :players, :is_admin, false, false
  end
end
