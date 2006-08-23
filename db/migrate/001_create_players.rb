class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.column :name, :string
      t.column :full_name, :string
      t.column :abbreviation, :string
      t.column :password_hash, :string
      t.column :password_salt, :string
      t.column :is_admin, :boolean
    end
    unless $schema_generator
      admin = Player.create(:name => 'admin',
                            :password => 'trundle',
                            :password_confirmation => 'trundle',
                            :is_admin => true)
      admin.valid? or raise "No user created?"
    end
  rescue Exception => e
    drop_table :players
    raise e
  end

  def self.down
    drop_table :players
  end
end
