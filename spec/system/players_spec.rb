# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Players", type: :system do
  fixtures :players

  let(:admin) { players(:admin) }

  before do
    driven_by(:rack_test)
    admin.update!(password: "foobar")

    visit "/"
    fill_in "Naam", with: "admin"
    fill_in "Wachtwoord", with: "foobar"
    click_button "Inloggen"
  end

  it "enables the admin to create players" do
    click_link "Spelers"
    click_link "New player"
    fill_in :player_name, with: "newplayer"
    fill_in :player_full_name, with: "Roger N. Player"
    fill_in :player_abbreviation, with: "NP"
    fill_in :player_password, with: "foo-bar-321"
    fill_in :player_password_confirmation, with: "foo-bar-321"
    click_button "Aanmaken"
    expect(page).to have_text "Roger N. Player"
  end

  it "enables the admin to update players" do
    click_link "Spelers"
    find_all("a", text: "Bewerken")[1].click
    fill_in :player_full_name, with: "Not Your Original Name"
    click_button "Update"
    expect(page).to have_text "Not Your Original Name"
  end
end
