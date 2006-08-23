require 'ajax_scaffold'
require 'digest/sha2'

class Player < ActiveRecord::Base
  validates_presence_of :name, :password, :password_confirmation
  validates_confirmation_of :password
  validates_uniqueness_of :name
  validates_length_of :password, :minimum => 5, :message => "Password must be at least 5 characters"
  attr_reader :password
  #attr_accessor :password_confirmation

  SALT = 'change this to your own salt'

  @scaffold_columns = %w(name full_name abbreviation is_admin).map {|c|
    AjaxScaffold::ScaffoldColumn.new(self, {:name => c})
  }

  def password=(pass)
    if pass == "" then
      return
    end
    @password = pass
    self.password_hash = Digest::SHA256.hexdigest(pass + SALT)
    self.password_salt = SALT
  end
end
