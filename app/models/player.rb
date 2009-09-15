require 'ajax_scaffold'
require 'digest/sha2'

class Player < ActiveRecord::Base
  SALT = 'change this to your own salt'

  @scaffold_columns = %w(name full_name abbreviation is_admin).map {|c|
    AjaxScaffold::ScaffoldColumn.new(self, {:name => c})
  }

  def password=(pass)
    self.password_hash = Digest::SHA256.hexdigest(pass + SALT)
  end
end
