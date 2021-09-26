# frozen_string_literal: true

require "test_helper"

class PlaydateStatusTest < ActiveSupport::TestCase
  MainController::MIN_PLAYERS = 2

  describe ".calculate" do
    it "sets code to no for a bad day" do
      [:matijs, :robert].each do |p|
        players(p).availabilities.create!(
          playdate: playdates(:today),
          status: Availability::STATUS_NEE
        )
      end

      result = PlaydateStatus.calculate(playdates, players)
      _(result[playdates(:today)][:code]).must_equal 0
    end
  end
end
