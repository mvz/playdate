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

    it "assigns to @player" do
      post :create, params: {player: player_params}, session: adminsession
      expect(assigns(:player)).not_to be_nil
    end

    it "redirects to the player list with a message" do
      post :create, params: {player: player_params}, session: adminsession
      aggregate_failures do
        expect(response).to redirect_to players_path
        expect(request).to set_flash[:notice].to I18n.t("flash.players.create.notice")
      end
    end

    it "increases the number of players" do
      expect { post :create, params: {player: player_params}, session: adminsession }
        .to change(Player, :count).by 1
    end
  end

  describe "#destroy" do
    let(:player) { players(:matijs) }

    it "redirects to the player list with a message" do
      post :destroy, params: {id: player.id}, session: adminsession
      aggregate_failures do
        expect(response).to redirect_to players_path
        expect(request).to set_flash[:notice].to I18n.t("flash.players.destroy.notice")
      end
    end

    it "decreases the number of players" do
      expect { post :destroy, params: {id: player.id}, session: adminsession }
        .to change(Player, :count).by(-1)
    end

    it "destroys the player's availabilities" do
      num_player_avs = player.availabilities.count
      expect(num_player_avs).to be > 0
      expect { post :destroy, params: {id: player.id}, session: adminsession }
        .to change(Availability, :count).by(-num_player_avs)
    end

    describe "when attempting to destroy onesself" do
      let(:player) { players(:admin) }

      it "does not reduce the number of players" do
        expect { post :destroy, params: {id: player.id}, session: adminsession }
          .not_to change(Player, :count)
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

    it "redirects to the player list with a message" do
      post :update, params: {id: 1, player: player_params}, session: adminsession
      aggregate_failures do
        expect(response).to redirect_to players_path
        expect(request).to set_flash[:notice].to I18n.t("flash.players.update.notice")
      end
    end
  end
end
