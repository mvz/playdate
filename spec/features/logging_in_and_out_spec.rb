# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Logging in and out", type: :feature do
  fixtures :players

  let(:admin) { players(:admin) }

  before do
    admin.update!(password: "foobar")
  end

  scenario "User logs in and out" do
    visit "/"
    fill_in "Naam", with: "admin"
    fill_in "Wachtwoord", with: "foobar"
    click_button "Inloggen"

    expect(page).to have_text("Ingelogd als #{admin.full_name}")

    click_link "Uitloggen"

    aggregate_failures do
      expect(page).not_to have_text("Ingelogd als #{admin.full_name}")
      expect(page).to have_text "Inloggen in Playdate"
    end
  end
end
