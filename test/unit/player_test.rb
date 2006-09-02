require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < Test::Unit::TestCase
  fixtures :players
  fixtures :playdates
  fixtures :availabilities

  # TODO: More tests!!

  NEW_PLAYER = {:name => 'Testy', :password => 'test123', :password_confirmation => 'test123'}
  REQ_ATTR_NAMES = %w(name)
  DUPLICATE_ATTR_NAMES = %w(name)

  def setup
    # Retrieve fixtures via their name
    @matijs = players(:matijs)
    @friday = playdates(:friday)
    @saturday = playdates(:saturday)
    @onfriday = availabilities(:onfriday)
    @onsaturday = availabilities(:onsaturday)
  end

  def test_raw_validation
    player = Player.new
    assert !player.valid?, "Player should not be valid without initialisation parameters"
    REQ_ATTR_NAMES.each {|attr_name| assert player.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"}
  end

  def test_new
    player = Player.new(NEW_PLAYER)
    assert player.valid?, "Player should be valid"
    assert_equal NEW_PLAYER[:name], player[:name], "Player.@name incorrect"
    assert player.check_password(NEW_PLAYER[:password]), "Password set incorrectly"
  end

  def test_validates_presence_of
    REQ_ATTR_NAMES.each do |attr_name|
      tmp_player = NEW_PLAYER.clone
      tmp_player.delete attr_name.to_sym
      player = Player.new(tmp_player)
      assert !player.valid?, "Player should be invalid, as @#{attr_name} is invalid"
      assert player.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    end
  end

  def test_password
    @matijs.password = "zoppa"
    assert @matijs.check_password("zoppa")
  end

  def test_duplicate
    current_player = Player.find_first
    DUPLICATE_ATTR_NAMES.each do |attr_name|
      player = Player.new(NEW_PLAYER.merge(attr_name.to_sym => current_player[attr_name]))
      assert !player.valid?, "Player should be invalid, as @#{attr_name} is a duplicate"
      assert player.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    end
  end

  def test_availabilities_by_day
    avs = @matijs.availabilities_by_day
    assert avs.length == 2, "Expected 2 availabilities"
    assert_equal({ @friday.day => @onfriday, @saturday.day => @onsaturday },
                 avs, "Wrong contents for avs" )
  end

  def test_associations
    avs = @matijs.availabilities.sort {|a,b| a.id <=> b.id }
    assert avs.length == 2, "Expected 2 availabilities"
    assert_equal( [ @onfriday, @onsaturday ], avs, "Did not get right availabilities for matijs" )
    pds = @matijs.playdates.sort {|a,b| a.id <=> b.id }
    assert pds.length == 2, "Expected 2 playdates"
    assert_equal( [ @friday, @saturday ], pds, "Did not get right playdates for matijs" )
  end
end

