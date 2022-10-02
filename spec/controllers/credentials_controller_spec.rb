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

  it "update_password" do
    post :update, params: {player: {password: "slurp", password_confirmation: "slurp"}}
    expect(response).to redirect_to controller: "session", action: "new"
    post :update,
      params: {player: {password: "slurp", password_confirmation: "slurp"}},
      session: playersession
    expect(response).to redirect_to controller: "main", action: "index"
    post :update,
      params: {player: {password: "slu", password_confirmation: "slurp"}},
      session: playersession
    expect(response).to be_successful
  end

  private

  def playersession
    {user_id: players(:matijs).id}
  end
end
