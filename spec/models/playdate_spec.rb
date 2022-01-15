# frozen_string_literal: true

require "rails_helper"

RSpec.describe Playdate, type: :model do
  fixtures :playdates

  required_attributes = %w[day].freeze
  NEW_PARAMS = {day: "2006-01-10"}.freeze

  it "raw_validation" do
    dt = described_class.new
    refute dt.valid?, "Playdate should not be valid without initialisation parameters"
    required_attributes.each do |attr_name|
      assert dt.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  it "fixtures_valid" do
    [:friday, :saturday].each do |p|
      assert playdates(p).valid?, "Playdate #{p} should be valid"
    end
  end

  it "new" do
    dt = described_class.new(NEW_PARAMS)
    assert dt.valid?, "Availability should be valid"
    assert_equal Date.new(2006, 1, 10), dt.day, "Playdate.day incorrect"
  end

  it "duplicate" do
    current = described_class.first
    playdate = described_class.new(day: current[:day])
    refute playdate.valid?, "Player should be invalid, as @day is a duplicate"
    assert playdate.errors[:day].any?, "Should be an error message for :day"
  end

  it "to_s" do
    assert_equal "2006-02-10", playdates(:friday).to_s
  end
end
