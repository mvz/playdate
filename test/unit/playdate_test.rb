require File.dirname(__FILE__) + '/../test_helper'

class PlaydateTest < Test::Unit::TestCase
  fixtures :playdates

  REQ_ATTR_NAMES = %w(day)
  DUPLICATE_ATTR_NAMES = %w(day)
  NEW_PARAMS = { :day => "2006-01-10" }

  def test_raw_validation
    dt = Playdate.new
    assert !dt.valid?, "Playdate should not be valid without initialisation parameters"
    REQ_ATTR_NAMES.each {|attr_name|
      assert dt.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    }
  end

  def test_new
    dt = Playdate.new(NEW_PARAMS)
    assert dt.valid?, "Availability should be valid"
    assert_equal Date.new(2006,1,10), dt.day, "Playdate.day incorrect"
  end

  def test_duplicate
    current = Playdate.find_first
    playdate = Playdate.new(:day => current[:day])
    assert !playdate.valid?, "Player should be invalid, as @day is a duplicate"
    assert playdate.errors.invalid?(:day), "Should be an error message for :day"
  end

  def test_to_s
    assert_equal "2006-02-10", playdates(:friday).to_s
  end
end
