# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication system", type: :system do
  fixtures :players

  let(:admin) { players(:admin) }

  before do
    driven_by :selenium, using: :headless_firefox
    admin.update!(password: "foobar")
  end

  it "enables the user to log in and out" do
    visit "/"
    fill_in "Naam", with: "admin"
    fill_in "Wachtwoord", with: "foobar"
    click_button "Inloggen"

    expect(page).to have_text("Ingelogd als #{admin.full_name}")

    # FIXME: This shouldn't be needed.
    sleep 0.01

    click_link "Uitloggen"

    aggregate_failures do
      expect(page).not_to have_text("Ingelogd als #{admin.full_name}")
      expect(page).to have_text "Inloggen in Playdate"
    end
  end
end
