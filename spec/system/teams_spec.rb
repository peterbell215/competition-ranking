require 'rails_helper'

RSpec.describe "Teams", type: :system do
  before do
    # Create an admin user for authentication
    admin = FactoryBot.create(:admin)

    # Sign in as admin before each test
    visit new_user_session_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_button "Log in"
  end

  describe "creating a new team" do
    it "creates a team with valid attributes" do
      visit teams_path
      click_on "New team"

      fill_in "Name", with: "Test Team"
      fill_in "Description", with: "This is a test team created through system testing"

      click_on "Create Team"

      expect(page).to have_content "Team was successfully created"
      expect(page).to have_selector "h1", text: "Test Team"

      # Verify the team details are visible on the show page
      expect(page).to have_content "This is a test team created through system testing"

      # Verify the team was saved in the database with correct attributes
      team = Team.find_by(name: "Test Team")
      expect(team).not_to be_nil
      expect(team.name).to eq("Test Team")
      expect(team.description).to eq("This is a test team created through system testing")
    end

    it "shows validation errors when name is missing" do
      visit new_team_path

      fill_in "Description", with: "Team with missing name"
      click_on "Create Team"

      expect(page).to have_content "prohibited this team from being saved"
      expect(page).to have_content "Name can't be blank"

      # Make sure we're still on the new team form
      expect(page).to have_selector "h1", text: "New team"
    end

    it "creates a team without a description" do
      visit new_team_path

      fill_in "Name", with: "Team Without Description"

      expect {
        click_on "Create Team"
      }.to change(Team, :count).by(1)

      expect(page).to have_content "Team was successfully created"
      expect(page).to have_selector "h1", text: "Team Without Description"
    end
  end
end
