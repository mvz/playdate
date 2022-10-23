# frozen_string_literal: true

require "rails_helper"

RSpec.describe AvailabilitiesController, type: :controller do
  render_views
  fixtures :players, :playdates, :availabilities

  describe "when not logged in" do
    [:destroy, :create, :update, :edit, :new].product([:get, :post]) do |(a, m)|
      it "requires login for #{m} #{a}" do
        send m, a, params: {playdate_id: 1, id: 1}
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "when logged in as a regular player" do
    let(:playersession) { {user_id: players(:matijs).id} }

    [:destroy, :create, :update, :edit, :new].product([:get, :post]) do |(a, m)|
      it "denies access for #{m} #{a}" do
        send m, a, params: {playdate_id: 1, id: 1}, session: playersession
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "#destroy" do
    it "destroys the availability" do
      expect(Availability.find(1)).not_to be_nil

      delete "destroy", params: {playdate_id: 1, id: 1}, session: adminsession

      expect { Availability.find(1) }.to raise_error ActiveRecord::RecordNotFound
    end

    it "redirects to the playdate with a message" do
      delete "destroy", params: {playdate_id: 1, id: 1}, session: adminsession

      aggregate_failures do
        expect(response).to redirect_to playdate_path(1)
        expect(request).to set_flash[:notice]
          .to I18n.t("flash.availabilities.destroy.notice")
      end
    end
  end

  # Edit: Show edit screen.
  describe "edit" do
    it "renders the selected availability for editing" do
      get "edit", params: {playdate_id: 1, id: 1}, session: adminsession

      expect(response).to be_successful
      expect(response).to render_template "edit"

      expect(assigns(:availability)).not_to be_nil
      expect(assigns(:availability)).to be_valid

      expect(response.body).to have_css "h1", text: "Editing availability"
    end

    it "has a form that will use the PATCH method" do
      get "edit", params: {playdate_id: 1, id: 1}, session: adminsession

      expect(response.body)
        .to have_css("form[action=\"#{playdate_availability_path(1, 1)}\"]") { |form|
          form.has_css? "input[value='patch']", visible: :all
        }
    end

    it "refuses to edit an availability via the wrong playdate" do
      expect { get "edit", params: {playdate_id: 2, id: 1}, session: adminsession }
        .to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#update" do
    it "redirects to the playdate with a message" do
      put :update,
        params: {playdate_id: 1, id: 1,
                 availability: {status: Availability::STATUS_JA}},
        session: adminsession

      aggregate_failures do
        expect(response).to redirect_to playdate_path(1)
        expect(request).to set_flash[:notice]
          .to I18n.t("flash.availabilities.update.notice")
      end
    end
  end

  it "new" do
    get "new", params: {playdate_id: 1}, session: adminsession

    expect(response).to be_successful
    expect(response).to render_template "new"

    expect(assigns(:availability)).not_to be_nil

    expect(response.body).to have_css "h1", text: "New availability"
  end

  describe "#create" do
    it "creates a new availability" do
      expect do
        post :create,
          params: {
            playdate_id: playdates(:friday).id,
            availability: {player_id: players(:robert).id, status: 1}
          },
          session: adminsession
      end.to change(Availability, :count).by(1)
    end

    it "redirects to the playdate with a message" do
      post :create,
        params: {
          playdate_id: playdates(:friday).id,
          availability: {player_id: players(:robert).id, status: 1}
        },
        session: adminsession

      aggregate_failures do
        expect(response).to redirect_to playdate_path(1)
        expect(request).to set_flash[:notice]
          .to I18n.t("flash.availabilities.create.notice")
      end
    end
  end

  private

  def adminsession
    {user_id: players(:admin).id}
  end
end
