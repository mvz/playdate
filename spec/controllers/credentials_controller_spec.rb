# frozen_string_literal: true

require "rails_helper"

RSpec.describe CredentialsController, type: :controller do
  render_views
  fixtures :players

  it "edit_password" do
    get :edit
    expect(response).to redirect_to controller: "session", action: "new"
    get :edit, params: {}, session: playersession
    expect(response).to be_successful
    expect(response.body).to have_css "h1", text: "Wachtwoord wijzigen"
  end

  describe "#update" do
    it "requires login" do
      post :update,
        params: { player: { password: "slurp", password_confirmation: "slurp" } }
      expect(response).to redirect_to controller: "session", action: "new"
    end

    it "updates the password" do
      matijs = players(:matijs)
      post :update,
        params: { player: { password: "slurp", password_confirmation: "slurp" } },
        session: playersession
      expect(response).to redirect_to controller: "main", action: "index"
      expect(matijs.reload.check_password("slurp")).to be_truthy
    end

    it "renders edit on failures" do
      post :update,
        params: { player: { password: "slu", password_confirmation: "slurp" } },
        session: playersession
      expect(response).to render_template :edit
      expect(response).to be_unprocessable
    end
  end

  private

  def playersession
    { user_id: players(:matijs).id }
  end
end
