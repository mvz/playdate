# frozen_string_literal: true

require "rails_helper"

RSpec.describe Player, type: :model do
  fixtures :players, :playdates, :availabilities

  let(:new_player_params) do
    { name: "Testy", password: "test123", password_confirmation: "test123" }.freeze
  end

  describe "validations" do
    let(:player) { described_class.new }

    it "requires name to be present" do
      expect(player).to validate_presence_of :name
    end

    it "requires name to be unique" do
      expect(player).to validate_uniqueness_of :name
    end

    it "requires password to have at least 5 characters" do
      expect(player).to validate_length_of(:password).is_at_least 5
    end

    it "allows setting blank password once password has been set" do
      player.password = "zoppa"
      expect(player).to allow_value("").for :password
    end

    it "allows is_admin to be false or true, but not nil" do
      aggregate_failures do
        expect(player).to allow_values(true, false).for :is_admin
        expect(player).not_to allow_value(nil).for :is_admin
      end
    end
  end

  it "fixtures_valid" do
    [:admin, :matijs, :robert].each do |p|
      expect(players(p)).to be_valid
    end
  end

  it "new" do
    player = described_class.new(new_player_params)
    aggregate_failures do
      expect(player).to be_valid
      expect(player[:name]).to eq new_player_params[:name]
      expect(player.check_password(new_player_params[:password])).to be true
    end
  end

  describe "#check_password" do
    it "returns true if the password matches" do
      player = players(:matijs)
      player.password = "zoppa"
      expect(player.check_password("zoppa")).to be true
    end

    it "returns nil if the password doesn't match" do
      player = players(:matijs)
      player.password = "zoppa"
      expect(player.check_password("zopp")).to be_nil
    end
  end

  describe ".authenticate" do
    it "returns the requested user if the password matches" do
      player = players(:matijs)
      player.password = "zoppa"
      player.save!
      expect(described_class.authenticate("matijs", "zoppa")).to eq player
    end

    it "does not return the requested user if the password doesn't match" do
      player = players(:matijs)
      player.password = "zoppa"
      player.save!
      expect(described_class.authenticate("matijs", "zopp")).to be_nil
    end
  end

  describe "#availabilities" do
    it "returns associated availabilities" do
      player = players(:matijs)
      expect(player.availabilities)
        .to contain_exactly availabilities(:onfriday), availabilities(:onsaturday)
    end
  end

  describe "#playdates" do
    it "returns associated playdates" do
      player = players(:matijs)
      expect(player.playdates)
        .to contain_exactly playdates(:friday), playdates(:saturday)
    end
  end
end
