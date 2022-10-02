# frozen_string_literal: true

require "rails_helper"

RSpec.describe Player, type: :model do
  fixtures :players, :playdates, :availabilities

  NEW_PLAYER = {name: "Testy", password: "test123", password_confirmation: "test123"}.freeze

  before do
    @matijs = players(:matijs)
    @friday = playdates(:friday)
    @saturday = playdates(:saturday)
    @onfriday = availabilities(:onfriday)
    @onsaturday = availabilities(:onsaturday)
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
  end

  it "fixtures_valid" do
    [:admin, :matijs, :robert].each do |p|
      expect(players(p)).to be_valid
    end
  end

  it "new" do
    player = described_class.new(NEW_PLAYER)
    expect(player).to be_valid
    expect(player[:name]).to eq NEW_PLAYER[:name]
    expect(player.check_password(NEW_PLAYER[:password])).to be true
  end

  it "password_and_authenticate" do
    @matijs.password = "zoppa"
    expect(@matijs.check_password("zoppa")).to be true
    @matijs.save!
    expect(described_class.authenticate("matijs", "zoppa")).to eq @matijs
  end

  it "associations" do
    avs = @matijs.availabilities.sort_by(&:id)
    expect(avs.length).to eq 2
    expect(avs).to eq [@onfriday, @onsaturday]
    pds = @matijs.playdates.sort_by(&:id)
    expect(pds.length).to eq 2
    expect(pds).to eq [@friday, @saturday]
  end
end
