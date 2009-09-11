require File.dirname(__FILE__) + '/../test_helper'

class PlayersControllerTest < ActionController::TestCase
  NEW_PLAYER = {:name => 'Testy', :password => 'test123', :password_confirmation => 'test123'}
  REDIRECT_TO_MAIN = {:controller => 'players', :action => 'index'}

  # TODO: Clean this up
  def setup
    @controller = PlayersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @first = Player.find(:first)
    @adminsession = {:user_id => players(:admin).id }
    @playersession = {:user_id => players(:matijs).id }
  end

  def test_authorization
    [:create, :destroy, :update].each do |a|
      [:get, :post].each do |m|
        [
          [{}, "login", "login"],
          [@playersession, "main", "index"]
        ].each do |session,controller,action|
          [ lambda { method(m).call(a, {}, session) } ].each do |e|
            e.call
            assert_redirected_to :controller => controller,
              :action => action
          end
        end
      end
    end
  end

  def test_create
    player_count = Player.find(:all).length
    post :create, {:player => NEW_PLAYER}, @adminsession
    player = check_attrs(%w(player))
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
    assert_equal player_count + 1, Player.find(:all).length, "Expected an additional Player"
  end

  def test_update
    player_count = Player.find(:all).length
    post :update,
      {:id => @first.id, :player => @first.attributes.merge(NEW_PLAYER)},
      @adminsession
    player = check_attrs(%w(player))
    player.reload
    NEW_PLAYER.each do |attr_name|
      assert_equal NEW_PLAYER[attr_name], player.attributes[attr_name], "@player.#{attr_name.to_s} incorrect"
    end
    assert_equal player_count, Player.find(:all).length, "Number of Players should be the same"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_destroy
    player_count = Player.find(:all).length


    player = players(:matijs)
    num_avs = Availability.count
    num_player_avs = player.availabilities.count
    assert num_player_avs > 0, "Test won't work if pd has no availabilities"

    post :destroy, {:id => players(:matijs).id}, @adminsession
    assert_response :redirect
    assert_equal player_count - 1, Player.find(:all).length, "Number of Players should be one less"
    assert_redirected_to REDIRECT_TO_MAIN

    assert_equal num_avs - num_player_avs, Availability.count
  end

  def test_destroy_using_get
    id = players(:matijs).id
    get 'destroy', {:id => id}, @adminsession
    assert_response :redirect
    assert_redirected_to :action => 'edit'

    assert_not_nil Playdate.find(id)
  end

  def test_cannot_destroy_self
    player_count = Player.find(:all).length
    post :destroy, {:id => players(:admin).id}, @adminsession
    assert_equal player_count, Player.find(:all).length, "Number of Players should stay the same"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
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
