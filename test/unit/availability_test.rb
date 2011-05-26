require File.dirname(__FILE__) + '/../test_helper'

class AvailabilityTest < ActiveSupport::TestCase
  REQ_ATTR_NAMES = %w(player playdate)

  def test_raw_validation
    availability = Availability.new
    assert !availability.valid?, "Availability should not be valid without initialisation parameters"
    REQ_ATTR_NAMES.each {|attr_name|
      assert availability.errors[attr_name.to_sym].any?, "Should be an error message for :#{attr_name}"
    }
  end

  def test_new
    new_params = { :player_id => players(:robert).id, :playdate_id => playdates(:friday).id, :status => 1 }
    availability = Availability.new(new_params)
    availability.valid?
    assert availability.valid?, "Availability should be valid"
    assert availability.status == 1
    new_params.each_pair do |attr_name,attr_value|
      assert_equal attr_value, availability[attr_name], "Availability.@#{attr_name.to_s} incorrect"
    end
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
    assert_equal "+", availabilities(:onfriday).status_character
    @onsaturday = availabilities(:onsaturday)
    assert_equal "h", @onsaturday.status_character
    @onsaturday.status = Availability::STATUS_NEE
    assert_equal "&minus;", @onsaturday.status_character
    @onsaturday.status = Availability::STATUS_MISSCHIEN
    assert_equal "?", @onsaturday.status_character
  end
end
