# frozen_string_literal: true

require "rails_helper"

RSpec.describe Availability, type: :model do
  fixtures :players, :playdates, :availabilities

  required_attributes = %w[player playdate].freeze

  it "raw_validation" do
    availability = Availability.new
    refute availability.valid?
    required_attributes.each do |attr_name|
      assert availability.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  it "new" do
    availability = Availability.new

    availability.player = players(:robert)
    availability.playdate = playdates(:friday)
    availability.status = Availability::STATUS_JA

    assert availability.valid?
    assert_equal 1, availability.status
    assert_equal players(:robert), availability.player
    assert_equal playdates(:friday), availability.playdate
  end

  it "fixtures_valid" do
    [:onfriday, :onsaturday].each do |a|
      assert availabilities(a).valid?, "Availability #{a} should be valid"
    end
  end

  it "constants" do
    assert_equal 4, Availability::VALUES.length
  end

  it "status_character" do
    assert_equal "+", availabilities(:onfriday).status_character
    @onsaturday = availabilities(:onsaturday)
    assert_equal "h", @onsaturday.status_character
    @onsaturday.status = Availability::STATUS_NEE
    assert_equal "−", @onsaturday.status_character
    @onsaturday.status = Availability::STATUS_MISSCHIEN
    assert_equal "?", @onsaturday.status_character
  end
end
