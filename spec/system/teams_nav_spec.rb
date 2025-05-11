require 'rails_helper'

RSpec.describe "Teams Navigation", type: :system do
  let(:admin) { admin = FactoryBot.create(:admin) }

  # This test focuses on verifying nav bar navigation
  describe "navigating to Teams through navbar" do
    before do
      # Sign in as admin
      visit new_user_session_path
      fill_in "Email", with: admin.email
      fill_in "Password", with: "password"
      click_button "Log in"
    end

    it "can navigate to the Teams page through the navbar" do
      # First check that we're logged in
      expect(page).to have_content(admin.name)
      
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