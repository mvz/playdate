class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.column :name, :string
      t.column :full_name, :string
      t.column :abbreviation, :string
      t.column :password_hash, :string
      t.column :is_admin, :boolean
    end
    Player.create(:name => 'admin', :password => 'trundle', :is_admin => true)
  rescue Exception => e
    drop_table :players
    raise e
  end

  def self.down
    drop_table :players
  end
end
