require File.dirname(__FILE__) + '/../test_helper'
require 'players_controller'

# Re-raise errors caught by the controller.
class PlayersController; def rescue_action(e) raise e end; end

class PlayersControllerTest < Test::Unit::TestCase
  fixtures :players

  NEW_PLAYER = {:name => 'Testy', :password => 'test123', :password_confirmation => 'test123'}
  REDIRECT_TO_MAIN = {:action => 'list'} # put hash or string redirection that you normally expect

  def setup
    @controller = PlayersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @first = Player.find(:first)
    @adminsession = {:user_id => players(:admin).id }
    @playersession = {:user_id => players(:matijs).id }
  end

  def test_authorization
    [:component, :create, :component_update, :destroy].each do |a|
      [:get, :post].each do |m|
        {"login" => {}, "main" => @playersession}.each do |redirect,session|
          [ lambda { method(m).call(a, {}, session) },
            lambda { xhr m, a, {}, session } ].each do |e|
            e.call
            assert_redirected_to :controller => redirect
          end
        end
      end
    end
  end

  def test_component
    get :component, {}, @adminsession
    assert_response :success
    assert_template 'players/component'
    players = check_attrs(%w(players))
    assert_equal Player.find(:all).length, players.length, "Incorrect number of players shown"
  end

  def test_component_update
    get :component_update, {}, @adminsession
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_component_update_xhr
    xhr :get, :component_update, {}, @adminsession
    assert_response :success
    assert_template 'players/component'
    players = check_attrs(%w(players))
    assert_equal Player.find(:all).length, players.length, "Incorrect number of players shown"
  end

  def test_create
    player_count = Player.find(:all).length
    post :create, {:player => NEW_PLAYER}, @adminsession
    player, successful = check_attrs(%w(player successful))
    assert successful, "Should be successful"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
    assert_equal player_count + 1, Player.find(:all).length, "Expected an additional Player"
  end

  def test_create_xhr
    player_count = Player.find(:all).length
    xhr :post, :create, {:player => NEW_PLAYER}, @adminsession
    player, successful = check_attrs(%w(player successful))
    assert successful, "Should be successful"
    assert_response :success
    assert_template 'create.rjs'
    assert_equal player_count + 1, Player.find(:all).length, "Expected an additional Player"
  end

  def test_update
    player_count = Player.find(:all).length
    post :update,
      {:id => @first.id, :player => @first.attributes.merge(NEW_PLAYER)},
      @adminsession
    player, successful = check_attrs(%w(player successful))
    assert successful, "Should be successful"
    player.reload
    NEW_PLAYER.each do |attr_name|
      assert_equal NEW_PLAYER[attr_name], player.attributes[attr_name], "@player.#{attr_name.to_s} incorrect"
    end
    assert_equal player_count, Player.find(:all).length, "Number of Players should be the same"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_update_xhr
    player_count = Player.find(:all).length
    xhr :post, :update,
      {:id => @first.id, :player => @first.attributes.merge(NEW_PLAYER)},
      @adminsession
    player, successful = check_attrs(%w(player successful))
    assert successful, "Should be successful"
    player.reload
    NEW_PLAYER.each do |attr_name|
      assert_equal NEW_PLAYER[attr_name], player.attributes[attr_name], "@player.#{attr_name.to_s} incorrect"
    end
    assert_equal player_count, Player.find(:all).length, "Number of Players should be the same"
    assert_response :success
    assert_template 'update.rjs'
  end

  def test_destroy
    player_count = Player.find(:all).length
    post :destroy, {:id => @first.id}, @adminsession
    assert_response :redirect
    assert_equal player_count - 1, Player.find(:all).length, "Number of Players should be one less"
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_destroy_xhr
    player_count = Player.find(:all).length
    xhr :post, :destroy, {:id => @first.id}, @adminsession
    assert_response :success
    assert_equal player_count - 1, Player.find(:all).length, "Number of Players should be one less"
    assert_template 'destroy.rjs'
  end

protected
  # Could be put in a Helper library and included at top of test class
  def check_attrs(attr_list)
    attrs = []
    attr_list.each do |attr_sym|
      attr = assigns(attr_sym.to_sym)
      assert_not_nil attr,       "Attribute @#{attr_sym} should not be nil"
      assert !attr.new_record?,  "Should have saved the @#{attr_sym} obj" if attr.class == ActiveRecord
      attrs << attr
    end
    attrs.length > 1 ? attrs : attrs[0]
  end
end
