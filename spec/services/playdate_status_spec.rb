# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaydateStatus do
  MainController::MIN_PLAYERS = 2

  fixtures :players, :playdates

  describe ".calculate" do
    it "sets code to no for a bad day" do
      [:matijs, :robert].each do |p|
        players(p).availabilities.create!(
          playdate: playdates(:today),
          status: Availability::STATUS_NEE
        )
      end

      result = described_class.calculate(playdates, players)
      expect(result[playdates(:today)][:code]).to eq 0
    end
  end
end
