# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Availibilities", type: :system do
  fixtures :players, :playdates, :availabilities

  let(:admin) { players(:admin) }

  before do
    driven_by(:rack_test)

    visit "/"
    fill_in Player.human_attribute_name(:email), with: "admin@example.com"
    fill_in Player.human_attribute_name(:password), with: "foobar"
    click_button "Inloggen"
  end

  it "enables the admin to create availabilities" do
    click_link "Speeldagen"
    within first("td", text: "Tonen") do
      click_link "Tonen"
    end
    expect(page).not_to have_text players(:robert).name
    click_link "Beschikbaarheid toevoegen"
    select players(:robert).name, from: :availability_player_id
    click_button "Save"
    expect(page).to have_text players(:robert).name
    expect(page).to have_text "Bewerken"
  end

  it "enables the admin to destroy availabilities from the playdate page" do
    click_link "Speeldagen"
    within first("td", text: "Tonen") do
      click_link "Tonen"
    end
    expect(page).to have_text players(:matijs).name
    click_button "Verwijderen"
    expect(page).not_to have_text players(:matijs).name
  end

  it "enables the admin to destroy an availability from its edit page" do
    click_link "Speeldagen"
    within first("td", text: "Tonen") do
      click_link "Tonen"
    end
    expect(page).to have_text players(:matijs).name
    click_link "Bewerken"
    click_button "Destroy"
    expect(page).not_to have_text players(:matijs).name
  end
end
