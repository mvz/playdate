# frozen_string_literal: true

require "rails_helper"

RSpec.describe CredentialsController, type: :controller do
  render_views
  fixtures :players

  it "edit_password" do
    get :edit
    assert_response :redirect
    assert_redirected_to controller: "session", action: "new"
    get :edit, params: {}, session: playersession
    assert_response :success
    assert_select "h1", "Wachtwoord wijzigen"
  end

  it "update_password" do
    post :update, params: {player: {password: "slurp", password_confirmation: "slurp"}}
    assert_response :redirect
    assert_redirected_to controller: "session", action: "new"
    post :update,
      params: {player: {password: "slurp", password_confirmation: "slurp"}},
      session: playersession
    assert_response :redirect
    assert_redirected_to controller: "main", action: "index"
    post :update,
      params: {player: {password: "slu", password_confirmation: "slurp"}},
      session: playersession
    assert_response :success
  end

  private

  def playersession
    {user_id: players(:matijs).id}
  end
end
