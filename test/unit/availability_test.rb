require File.dirname(__FILE__) + '/../test_helper'

class AvailabilityTest < Test::Unit::TestCase
  fixtures :players
  fixtures :playdates
  fixtures :availabilities

  REQ_ATTR_NAMES = %w(player_id playdate_id status)

  def setup
    @new_params = { :player_id => players(:robert).id, :playdate_id => playdates(:friday).id, :status => 1 }
  end

  def test_raw_validation
    availability = Availability.new
    assert !availability.valid?, "Availability should not be valid without initialisation parameters"
    REQ_ATTR_NAMES.each {|attr_name|
      assert availability.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    }
  end

  def test_new
    availability = Availability.new(@new_params)
    assert availability.valid?, "Availability should be valid"
    assert availability.status == 1
    @new_params.each_pair do |attr_name,attr_value|
      assert_equal attr_value, availability[attr_name], "Player.@#{attr_name.to_s} incorrect"
    end
  end
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
