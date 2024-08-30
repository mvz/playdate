# frozen_string_literal: true

require "rails_helper"

RSpec.describe Playdate, type: :model do
  fixtures :playdates

  let(:new_params) { { day: "2006-01-10" } }

  describe "validations" do
    let(:playdate) { described_class.new }

    it "requires day to be present" do
      expect(playdate).to validate_presence_of :day
    end

    it "requires day to be unique" do
      expect(playdate).to validate_uniqueness_of :day
    end
  end

  it "fixtures_valid" do
    [:friday, :saturday].each do |p|
      expect(playdates(p)).to be_valid
    end
  end

  it "new" do
    dt = described_class.new(new_params)
    expect(dt).to be_valid
    expect(dt.day).to eq Date.new(2006, 1, 10)
  end

  it "to_s" do
    expect(playdates(:friday).to_s).to eq "2006-02-10"
  end
end
