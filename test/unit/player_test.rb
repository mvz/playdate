require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < Test::Unit::TestCase
  fixtures :players

	NEW_PLAYER = {}	# e.g. {:name => 'Test Player', :description => 'Dummy'}
	REQ_ATTR_NAMES 			 = %w( ) # name of fields that must be present, e.g. %(name description)
	DUPLICATE_ATTR_NAMES = %w( ) # name of fields that cannot be a duplicate, e.g. %(name description)

  def setup
    # Retrieve fixtures via their name
    # @first = players(:first)
  end

  def test_raw_validation
    player = Player.new
    if REQ_ATTR_NAMES.blank?
      assert player.valid?, "Player should be valid without initialisation parameters"
    else
      # If Player has validation, then use the following:
      assert !player.valid?, "Player should not be valid without initialisation parameters"
      REQ_ATTR_NAMES.each {|attr_name| assert player.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"}
    end
  end

	def test_new
    player = Player.new(NEW_PLAYER)
    assert player.valid?, "Player should be valid"
   	NEW_PLAYER.each do |attr_name|
      assert_equal NEW_PLAYER[attr_name], player.attributes[attr_name], "Player.@#{attr_name.to_s} incorrect"
    end
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

	def test_duplicate
    current_player = Player.find_first
   	DUPLICATE_ATTR_NAMES.each do |attr_name|
   		player = Player.new(NEW_PLAYER.merge(attr_name.to_sym => current_player[attr_name]))
			assert !player.valid?, "Player should be invalid, as @#{attr_name} is a duplicate"
    	assert player.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
		end
	end
end

