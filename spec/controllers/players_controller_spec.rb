# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlayersController, type: :controller do
  fixtures :players, :playdates, :availabilities

  let(:adminsession) { {user_id: players(:admin).id} }

  describe "when not logged in" do
    [:create, :destroy, :update].product([:get, :post]) do |(a, m)|
      it "requires login for #{m} #{a}" do
        send m, a, params: {id: 1}
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "when logged in as a regular player" do
    let(:playersession) { {user_id: players(:matijs).id} }

    [:create, :destroy, :update].product([:get, :post]) do |(a, m)|
      it "denies access for #{m} #{a}" do
        send m, a, params: {id: 1}, session: playersession
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "#index" do
    render_views

    before do
      get :index, params: {}, session: adminsession
    end

    it "renders index" do
      expect(response).to render_template "index"
    end

    it "has the correct heading" do
      expect(response.body).to have_css "h1", text: "Spelers"
    end
  end

  describe "#edit" do
    render_views

    before do
      get :edit, params: {id: 1}, session: adminsession
    end

    it "renders edit" do
      expect(response).to render_template "edit"
    end

    it "has the correct heading" do
      expect(response.body).to have_css "h1", text: "Speler bewerken"
    end
  end

  describe "#new" do
    render_views

    before do
      get :new, params: {}, session: adminsession
    end

    it "renders new" do
      expect(response).to render_template "new"
    end

    it "has the correct heading" do
      expect(response.body).to have_css "h1", text: "Nieuwe speler"
    end
  end

  describe "#create" do
    let(:player_params) do
      {name: "new",
       full_name: "New Name",
       abbreviation: "nn",
       password: "test123",
       password_confirmation: "test123"}
    end

    before do
      @player_count = Player.all.length
      post :create, params: {player: player_params}, session: adminsession
    end

    it "assigns to @player" do
      expect(assigns(:player)).not_to be_nil
    end

    it "redirects to the player list" do
      expect(response).to redirect_to players_path
    end

    it "increases the number of players" do
      expect(Player.all.length).to eq @player_count + 1
    end
  end

  describe "#destroy" do
    let(:player) { players(:matijs) }

    before do
      @player_count = Player.all.length
      @num_avs = Availability.count
      @num_player_avs = player.availabilities.count
      post :destroy, params: {id: player.id}, session: adminsession
    end

    it "redirects to the player list" do
      expect(response).to redirect_to players_path
    end

    it "decreases the number of players" do
      expect(Player.all.length).to eq @player_count - 1
    end

    it "destroys the player's availabilities" do
      expect(@num_player_avs).to be > 0
      expect(Availability.count).to eq @num_avs - @num_player_avs
    end

    describe "when attempting to destroy onesself" do
      let(:player) { players(:admin) }

      it "does not reduce the number of players" do
        expect(Player.all.length).to eq @player_count
      end
    end
  end

  describe "#update" do
    let(:player_params) do
      {name: "new",
       full_name: "New Name",
       abbreviation: "nn",
       is_admin: "true",
       default_status: Availability::STATUS_JA.to_s}
    end
    let(:expected_params) do
      ActionController::Parameters.new(player_params).permit!
    end

    it "updates all desired attributes" do
      adminsession
      player = instance_double(Player)
      allow(player).to receive(:update)
      allow(Player).to receive(:find).and_return(player)
      post :update, params: {id: 1, player: player_params}, session: adminsession
      expect(player).to have_received(:update).with(expected_params)
    end

    it "redirects to the player list" do
      post :update, params: {id: 1, player: player_params}, session: adminsession
      expect(response).to redirect_to players_path
    end
  end
end
