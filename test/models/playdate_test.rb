# frozen_string_literal: true

require 'test_helper'

class PlaydateTest < ActiveSupport::TestCase
  REQ_ATTR_NAMES = %w(day).freeze
  DUPLICATE_ATTR_NAMES = %w(day).freeze
  NEW_PARAMS = { day: '2006-01-10' }.freeze

  def test_raw_validation
    dt = Playdate.new
    assert_not dt.valid?, 'Playdate should not be valid without initialisation parameters'
    REQ_ATTR_NAMES.each do |attr_name|
      assert dt.errors[attr_name.to_sym].any?,
             "Should be an error message for :#{attr_name}"
    end
  end

  def test_fixtures_valid
    [:friday, :saturday].each do |p|
      assert playdates(p).valid?, "Playdate #{p} should be valid"
    end
  end

  def test_new
    dt = Playdate.new(NEW_PARAMS)
    assert dt.valid?, 'Availability should be valid'
    assert_equal Date.new(2006, 1, 10), dt.day, 'Playdate.day incorrect'
  end

  def test_duplicate
    current = Playdate.first
    playdate = Playdate.new(day: current[:day])
    assert_not playdate.valid?, 'Player should be invalid, as @day is a duplicate'
    assert playdate.errors[:day].any?, 'Should be an error message for :day'
  end

  def test_to_s
    assert_equal '2006-02-10', playdates(:friday).to_s
  end
end
