# frozen_string_literal: true

require "rails_helper"

RSpec.describe Player, type: :model do
  fixtures :players, :playdates, :availabilities

  NEW_PLAYER = {name: "Testy", password: "test123", password_confirmation: "test123"}.freeze
  required_attributes = %w[name].freeze
  DUPLICATE_ATTR_NAMES = %w[name].freeze

  before do
    @matijs = players(:matijs)
    @friday = playdates(:friday)
    @saturday = playdates(:saturday)
    @onfriday = availabilities(:onfriday)
    @onsaturday = availabilities(:onsaturday)
  end

  it "raw_validation" do
    player = described_class.new
    refute player.valid?, "Player should not be valid without initialisation parameters"
    required_attributes.each do |attr_name|
      assert player.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  it "fixtures_valid" do
    [:admin, :matijs, :robert].each do |p|
      assert players(p).valid?, "Player #{p} should be valid"
    end
  end

  it "new" do
    player = described_class.new(NEW_PLAYER)
    assert player.valid?, "Player should be valid"
    assert_equal NEW_PLAYER[:name], player[:name], "Player.@name incorrect"
    assert player.check_password(NEW_PLAYER[:password]), "Password set incorrectly"
  end

  it "validates_presence_of" do
    required_attributes.each do |attr_name|
      tmp_player = NEW_PLAYER.dup
      tmp_player.delete attr_name.to_sym
      player = described_class.new(tmp_player)
      refute player.valid?, "Player should be invalid, as @#{attr_name} is invalid"
      assert player.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  it "validates_length_of" do
    @matijs.password = "zop"
    refute @matijs.valid?, "Too short password should be invalid"
    # TODO: Do we need to make this test pass?
    # @matijs.password = ""
    # assert !@matijs.valid?, "Empty password should be invalid before setting"
    @matijs.password = "zoppa"
    assert @matijs.valid?, "Five char password should be valid"
    @matijs.password = ""
    assert @matijs.valid?, "Empty password should be valid after setting once"
  end

  it "password_and_authenticate" do
    @matijs.password = "zoppa"
    assert @matijs.check_password("zoppa")
    @matijs.save!
    assert_equal @matijs, described_class.authenticate("matijs", "zoppa")
  end

  it "duplicate" do
    current_player = described_class.first
    DUPLICATE_ATTR_NAMES.each do |attr_name|
      player = described_class.new(
        NEW_PLAYER.merge(attr_name.to_sym => current_player[attr_name])
      )
      refute player.valid?, "Player should be invalid, as @#{attr_name} is a duplicate"
      assert player.errors[attr_name.to_sym].any?,
        "Should be an error message for :#{attr_name}"
    end
  end

  it "associations" do
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
