# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionController, type: :controller do
  fixtures :players
  render_views

  it "login_intent" do
    get :new
    aggregate_failures do
      expect(response).to be_successful
      expect(response).to render_template "new"
      expect(response.body).to have_css "h1", text: "Inloggen in Playdate"
    end
  end

  it "login success" do
    matijs = players(:matijs)
    matijs.password = "gnoef!"
    matijs.password_confirmation = "gnoef!"
    matijs.save!
    post :create, params: { name: "matijs", password: "gnoef!" }
    expect(response).to redirect_to controller: "main", action: "index"
  end

  it "login failures" do
    matijs = players(:matijs)
    matijs.password = "gnoef!"
    matijs.password_confirmation = "gnoef!"
    matijs.save!
    post :create, params: { name: "matijs", password: "zonk" }
    aggregate_failures do
      expect(response).to be_unprocessable
      expect(response).to render_template "new"
    end
  end

  it "logout needs session" do
    get :edit
    expect(response).to be_redirect
  end

  it "logout intent" do
    get :edit, params: {}, session: playersession
    aggregate_failures do
      expect(response).to be_successful
      expect(session[:user_id]).not_to be_nil
      expect(response).to render_template "edit"
      expect(response.body).to have_css "h1", text: "Uitloggen"
    end
  end

  it "logout" do
    post :destroy, params: {}, session: playersession
    aggregate_failures do
      expect(response).to redirect_to controller: "session", action: "new"
      expect(session[:user_id]).to be_nil
    end
  end

  private

  def playersession
    { user_id: players(:matijs).id }
  end
end
