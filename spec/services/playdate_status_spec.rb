# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlaydateStatus do
  fixtures :players, :playdates

  before do
    stub_const("MainController::MIN_PLAYERS", 2)
  end

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
