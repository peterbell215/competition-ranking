require 'rails_helper'

RSpec.describe "Teams Management", type: :system do

  # This test focuses on verifying nav bar navigation
  describe "navigating to Teams through navbar" do
    it "can navigate to the Teams page through the navbar" do
      login
      goto_teams_page
    end

    it "creates a team with valid attributes" do
      login
      goto_teams_page

      # Click "New team" button to go to the new team form
      click_link "New team"

      # Fill out the form
      fill_in "Name", with: "Test Team"
      fill_in "Description", with: "This is a test team created through system testing"
      click_button "Create Team"

      # Verify the team was created successfully
      expect(page).to have_content "Team was successfully created"
      expect(page).to have_selector "h2", text: "Test Team"
      expect(page).to have_content "This is a test team created through system testing"

      # Verify data was saved correctly
      team = Team.find_by(name: "Test Team")
      expect(team).not_to be_nil
      expect(team.name).to eq("Test Team")
      expect(team.description).to eq("This is a test team created through system testing")

      # Verify that clicking on the Teams link in the navbar takes us to the teams index page
      visit rankings_path  # first go to another page
      click_link "Teams"   # then try to use the navbar
      expect(page).to have_current_path(teams_path)
    end

    def login
      admin = User.first

      # Sign in as admin
      visit new_user_session_path
      fill_in "Email", with: admin.email
      fill_in "Password", with: "password"
      click_button "Log in"

      expect(page).to have_content(admin.name)
    end

    def goto_teams_page
      # Go to the rankings page first
      visit rankings_path
      expect(page).to have_current_path(rankings_path)

      # We should see Teams in the navbar
      expect(page).to have_link("Teams")

      # Click on Teams in the navbar
      click_link "Teams"

      # Verify we're on the teams page
      expect(page).to have_current_path(teams_path)
      expect(page).to have_content("Teams")
      expect(page).to have_link("New team")
    end
  end
end

