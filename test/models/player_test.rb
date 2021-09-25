# frozen_string_literal: true

require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  # TODO: More tests!!

  NEW_PLAYER = {name: "Testy", password: "test123", password_confirmation: "test123"}.freeze
  REQ_ATTR_NAMES = %w[name].freeze
  DUPLICATE_ATTR_NAMES = %w[name].freeze

  def setup
    @matijs = players(:matijs)
    @friday = playdates(:friday)
    @saturday = playdates(:saturday)
    @onfriday = availabilities(:onfriday)
    @onsaturday = availabilities(:onsaturday)
  end

  def test_raw_validation
    player = Player.new
    assert_not player.valid?, "Player should not be valid without initialisation parameters"
    REQ_ATTR_NAMES.each do |attr_name|
      assert player.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  def test_fixtures_valid
    [:admin, :matijs, :robert].each do |p|
      assert players(p).valid?, "Player #{p} should be valid"
    end
  end

  def test_new
    player = Player.new(NEW_PLAYER)
    assert player.valid?, "Player should be valid"
    assert_equal NEW_PLAYER[:name], player[:name], "Player.@name incorrect"
    assert player.check_password(NEW_PLAYER[:password]), "Password set incorrectly"
  end

  def test_validates_presence_of
    REQ_ATTR_NAMES.each do |attr_name|
      tmp_player = NEW_PLAYER.dup
      tmp_player.delete attr_name.to_sym
      player = Player.new(tmp_player)
      assert_not player.valid?, "Player should be invalid, as @#{attr_name} is invalid"
      assert player.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  def test_validates_length_of
    @matijs.password = "zop"
    assert_not @matijs.valid?, "Too short password should be invalid"
    # TODO: Do we need to make this test pass?
    # @matijs.password = ""
    # assert !@matijs.valid?, "Empty password should be invalid before setting"
    @matijs.password = "zoppa"
    assert @matijs.valid?, "Five char password should be valid"
    @matijs.password = ""
    assert @matijs.valid?, "Empty password should be valid after setting once"
  end

  def test_password_and_authenticate
    @matijs.password = "zoppa"
    assert @matijs.check_password("zoppa")
    @matijs.save!
    assert_equal @matijs, Player.authenticate("matijs", "zoppa")
  end

  def test_duplicate
    current_player = Player.first
    DUPLICATE_ATTR_NAMES.each do |attr_name|
      player = Player.new(NEW_PLAYER.merge(attr_name.to_sym => current_player[attr_name]))
      assert_not player.valid?, "Player should be invalid, as @#{attr_name} is a duplicate"
      assert player.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  def test_associations
    avs = @matijs.availabilities.sort_by(&:id)
    assert_equal 2, avs.length, "Expected 2 availabilities"
    assert_equal [@onfriday, @onsaturday], avs,
      "Did not get right availabilities for matijs"
    pds = @matijs.playdates.sort_by(&:id)
    assert_equal 2, pds.length, "Expected 2 playdates"
    assert_equal [@friday, @saturday], pds,
      "Did not get right playdates for matijs"
  end
end
