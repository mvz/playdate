require 'test_helper'

class AvailabilityTest < ActiveSupport::TestCase
  REQ_ATTR_NAMES = %w(player playdate)

  def test_raw_validation
    availability = Availability.new
    assert !availability.valid?
    REQ_ATTR_NAMES.each {|attr_name|
      assert availability.errors[attr_name.to_sym].any?, "Should be an error message for :#{attr_name}"
    }
  end

  def test_new
    availability = Availability.new

    availability.player = players(:robert)
    availability.playdate = playdates(:friday)
    availability.status = Availability::STATUS_JA

    assert availability.valid?
    assert_equal 1, availability.status
    assert_equal players(:robert), availability.player
    assert_equal playdates(:friday), availability.playdate
  end

  def test_fixtures_valid
    [:onfriday, :onsaturday].each do |a|
      assert availabilities(a).valid?, "Availability #{a} should be valid"
    end
  end

  def test_constants
    assert Availability::VALUES.length == 4
  end

  def test_status_character
    assert_equal '+', availabilities(:onfriday).status_character
    @onsaturday = availabilities(:onsaturday)
    assert_equal 'h', @onsaturday.status_character
    @onsaturday.status = Availability::STATUS_NEE
    assert_equal '&minus;', @onsaturday.status_character
    @onsaturday.status = Availability::STATUS_MISSCHIEN
    assert_equal '?', @onsaturday.status_character
  end
end
