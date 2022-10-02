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

    expect(availability).to be_valid
    expect(availability.status).to eq 1
    expect(availability.player).to eq players(:robert)
    expect(availability.playdate).to eq playdates(:friday)
  end

  it "fixtures_valid" do
    [:onfriday, :onsaturday].each do |a|
      expect(availabilities(a)).to be_valid
    end
  end

  it "constants" do
    expect(Availability::VALUES.length).to eq 4
  end

  it "status_character" do
    expect(availabilities(:onfriday).status_character).to eq "+"
    @onsaturday = availabilities(:onsaturday)
    expect(@onsaturday.status_character).to eq "h"
    @onsaturday.status = Availability::STATUS_NEE
    expect(@onsaturday.status_character).to eq "−"
    @onsaturday.status = Availability::STATUS_MISSCHIEN
    expect(@onsaturday.status_character).to eq "?"
  end
end
