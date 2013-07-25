require File.dirname(__FILE__) + '/../test_helper'

class PlayersControllerTest < ActionController::TestCase
  NEW_PLAYER = {:name => 'Testy', :password => 'test123', :password_confirmation => 'test123'}
  REDIRECT_TO_MAIN = {:controller => 'players', :action => 'index'}

  def setup
    @adminsession = {:user_id => players(:admin).id }
  end

  def test_authorization
    playersession = {:user_id => players(:matijs).id }
    [
      [{}, "login", "login"],
      [playersession, "main", "index"]
    ].each do |session,controller,action|
      [:create, :destroy, :update].each do |a|
        [:get, :post].each do |m|
          [ lambda { method(m).call(a, {:id => 1}, session) } ].each do |e|
            e.call
            assert_redirected_to :controller => controller,
              :action => action
          end
        end
      end
    end
  end

  def test_index
    get :index, {}, @adminsession

    assert_template 'index'
    assert_select "h1", "Spelers"
  end

  def test_edit
    get :edit, {:id => 1}, @adminsession

    assert_template 'edit'
    assert_select "h1", "Speler bewerken"
  end

  def test_new
    get :new, {}, @adminsession

    assert_template 'new'
    assert_select "h1", "Nieuwe speler"
  end

  def test_create
    player_count = Player.all.length
    post :create, {:player => NEW_PLAYER}, @adminsession
    check_attrs(%w(player))
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
    assert_equal player_count + 1, Player.all.length, "Expected an additional Player"
  end

  def test_update
    @first = Player.first
    player_count = Player.all.length
    post :update,
      {:id => @first.id, :player => NEW_PLAYER},
      @adminsession
    player = check_attrs(%w(player))
    player.reload
    NEW_PLAYER.each do |attr_name|
      assert_equal NEW_PLAYER[attr_name], player.attributes[attr_name], "@player.#{attr_name.to_s} incorrect"
    end
    assert_equal player_count, Player.all.length, "Number of Players should be the same"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_destroy
    player_count = Player.all.length

    player = players(:matijs)
    num_avs = Availability.count
    num_player_avs = player.availabilities.count
    assert num_player_avs > 0, "Test won't work if pd has no availabilities"

    post :destroy, {:id => players(:matijs).id}, @adminsession
    assert_response :redirect
    assert_equal player_count - 1, Player.all.length, "Number of Players should be one less"
    assert_redirected_to REDIRECT_TO_MAIN

    assert_equal num_avs - num_player_avs, Availability.count
  end

  def test_cannot_destroy_self
    player_count = Player.all.length
    post :destroy, {:id => players(:admin).id}, @adminsession
    assert_equal player_count, Player.all.length, "Number of Players should stay the same"
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

describe PlayersController do
  let(:adminsession) { { :user_id => players(:admin).id } }

  before do
    adminsession
  end

  describe "#update" do
    let(:player_params) { { name: 'new',
                            full_name: 'New Name',
                            abbreviation: 'nn',
                            is_admin: true,
                            default_status: Availability::STATUS_JA.to_s } }
    it 'updates all desired attributes' do
      player = MiniTest::Mock.new
      player.expect(:update_attributes, true, [player_params.with_indifferent_access])
      Player.stub :find, player do
        post :update, {id: 1, player: player_params}, adminsession
      end
    end
  end
end
