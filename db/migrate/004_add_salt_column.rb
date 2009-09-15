#class BarePlayer < ActiveRecord::Base
#  include BareMigration
#end
class AddSaltColumn < ActiveRecord::Migration
  OLDSALT = 'rubadub-in-a-bun-with-boots-on'
  def self.up
    add_column :players, :password_salt, :string
    Player.reset_column_information
    Player.find(:all).each do |player|
      player.password_salt = OLDSALT
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
