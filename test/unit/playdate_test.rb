require File.dirname(__FILE__) + '/../test_helper'

class PlaydateTest < Test::Unit::TestCase
  fixtures :playdates

  REQ_ATTR_NAMES = %w(day)

  def setup
    @new_params = { :day => "2006-01-10" }
  end

  def test_raw_validation
    dt = Playdate.new
    assert !dt.valid?, "Playdate should not be valid without initialisation parameters"
    REQ_ATTR_NAMES.each {|attr_name|
      assert dt.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    }
  end

  def test_new
    dt = Playdate.new(@new_params)
    assert dt.valid?, "Availability should be valid"
    assert_equal Date.new(2006,1,10), dt.day, "Playdate.day incorrect"
  end
end
