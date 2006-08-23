class Availability < ActiveRecord::Base
  belongs_to :player
  belongs_to :playdate
end
