# frozen_string_literal: true

require "rails_helper"

RSpec.describe Availability, type: :model do
  fixtures :players, :playdates, :availabilities

  describe "validations" do
    let(:availability) { described_class.new }

    it "requires player to be present" do
      expect(availability).to belong_to :player
    end

    it "requires playdate to be present" do
      expect(availability).to belong_to :playdate
    end
  end

  it "new" do
    availability = described_class.new

    availability.player = players(:robert)
    availability.playdate = playdates(:friday)
    availability.status = Availability::STATUS_JA

    aggregate_failures do
      expect(availability).to be_valid
      expect(availability.status).to eq 1
      expect(availability.player).to eq players(:robert)
      expect(availability.playdate).to eq playdates(:friday)
    end
  end

  it "fixtures_valid" do
    [:onfriday, :onsaturday].each do |a|
      expect(availabilities(a)).to be_valid
    end
  end

  it "constants" do
    expect(Availability::VALUES.length).to eq 4
  end

  describe "#status_character" do
    let(:availability) { described_class.new }

    it "equals '+' for STATUS_JA" do
      availability.status = Availability::STATUS_JA
      expect(availability.status_character).to eq "+"
    end

    it "equals 'h' for STATUS_HUIS" do
      availability.status = Availability::STATUS_HUIS
      expect(availability.status_character).to eq "h"
    end

    it "equals '-' for STATUS_NEE" do
      availability.status = Availability::STATUS_NEE
      expect(availability.status_character).to eq "−"
    end

    it "equals '?' for STATUS_MISSCHIEN" do
      availability.status = Availability::STATUS_MISSCHIEN
      expect(availability.status_character).to eq "?"
    end
  end
end
