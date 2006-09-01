class Availability < ActiveRecord::Base
  belongs_to :player
  belongs_to :playdate
  validates_presence_of :player_id, :playdate_id, :status
  validates_uniqueness_of :playdate_id, :scope => [:player_id]
end
