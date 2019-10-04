# frozen_string_literal: true

require 'test_helper'

class PlayersControllerTest < ActionController::TestCase
  let(:adminsession) { { user_id: players(:admin).id } }

  describe 'when not logged in' do
    [:create, :destroy, :update].each do |a|
      [:get, :post].each do |m|
        it "requires login for #{m} #{a}" do
          send m, a, params: { id: 1 }
          assert_redirected_to login_path
        end
      end
    end
  end

  describe 'when logged in as a regular player' do
    let(:playersession) { { user_id: players(:matijs).id } }

    [:create, :destroy, :update].each do |a|
      [:get, :post].each do |m|
        it "denies access for #{m} #{a}" do
          send m, a, params: { id: 1 }, session: playersession
          assert_redirected_to root_path
        end
      end
    end
  end

  describe '#index' do
    render_views!

    before do
      get :index, params: {}, session: adminsession
    end

    it 'renders index' do
      assert_template 'index'
    end

    it 'has the correct heading' do
      assert_select 'h1', 'Spelers'
    end
  end

  describe '#edit' do
    render_views!

    before do
      get :edit, params: { id: 1 }, session: adminsession
    end

    it 'renders edit' do
      assert_template 'edit'
    end

    it 'has the correct heading' do
      assert_select 'h1', 'Speler bewerken'
    end
  end

  describe '#new' do
    render_views!

    before do
      get :new, params: {}, session: adminsession
    end

    it 'renders new' do
      assert_template 'new'
    end

    it 'has the correct heading' do
      assert_select 'h1', 'Nieuwe speler'
    end
  end

  describe '#create' do
    let(:player_params) do
      { name: 'new',
        full_name: 'New Name',
        abbreviation: 'nn',
        password: 'test123',
        password_confirmation: 'test123' }
    end

    before do
      @player_count = Player.all.length
      post :create, params: { player: player_params }, session: adminsession
    end

    it 'assigns to @player' do
      _(assigns(:player)).wont_be_nil
    end

    it 'redirects to the player list' do
      assert_redirected_to players_path
    end

    it 'increases the number of players' do
      assert_equal @player_count + 1, Player.all.length
    end
  end

  describe '#destroy' do
    let(:player) { players(:matijs) }

    before do
      @player_count = Player.all.length
      @num_avs = Availability.count
      @num_player_avs = player.availabilities.count
      post :destroy, params: { id: player.id }, session: adminsession
    end

    it 'redirects to the player list' do
      assert_redirected_to players_path
    end

    it 'decreases the number of players' do
      assert_equal @player_count - 1, Player.all.length
    end

    it "destroys the player's availabilities" do
      assert @num_player_avs > 0
      assert_equal @num_avs - @num_player_avs, Availability.count
    end

    describe 'when attempting to destroy onesself' do
      let(:player) { players(:admin) }

      it 'does not reduce the number of players' do
        assert_equal @player_count, Player.all.length
      end
    end
  end

  describe '#update' do
    let(:player_params) do
      { name: 'new',
        full_name: 'New Name',
        abbreviation: 'nn',
        is_admin: 'true',
        default_status: Availability::STATUS_JA.to_s }
    end
    let(:expected_params) do
      ActionController::Parameters.new(player_params).permit!
    end

    it 'updates all desired attributes' do
      adminsession
      player = MiniTest::Mock.new
      player.expect(:update, true, [expected_params])
      Player.stub :find, player do
        post :update, params: { id: 1, player: player_params }, session: adminsession
      end
      player.verify
    end

    it 'redirects to the player list' do
      post :update, params: { id: 1, player: player_params }, session: adminsession
      assert_redirected_to players_path
    end
  end
end
