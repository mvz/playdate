# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionController, type: :controller do
  fixtures :players
  render_views

  it "login_intent" do
    get :new
    expect(response).to be_successful
    expect(response).to render_template "new"
    expect(response.body).to have_css "h1", text: "Inloggen in Playdate"
  end

  it "login" do
    matijs = players(:matijs)
    matijs.password = "gnoef!"
    matijs.password_confirmation = "gnoef!"
    matijs.save!
    post :create, params: {name: "matijs", password: "gnoef!"}
    expect(response).to redirect_to controller: "main", action: "index"
    post :create, params: {name: "matijs", password: "zonk"}
    expect(response).to be_successful
    expect(response).to render_template "new"
  end

  it "logout_intent" do
    get :edit
    expect(response).to be_redirect
    get :edit, params: {}, session: playersession
    expect(response).to be_successful
    expect(session[:user_id]).not_to be_nil
    expect(response).to render_template "edit"
    expect(response.body).to have_css "h1", text: "Uitloggen"
  end

  it "logout" do
    post :destroy, params: {}, session: playersession
    expect(response).to redirect_to controller: "session", action: "new"
    expect(session[:user_id]).to be_nil
  end

  private

  def playersession
    {user_id: players(:matijs).id}
  end
end
