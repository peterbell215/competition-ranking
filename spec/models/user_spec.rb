require 'rails_helper'

RSpec.describe User, type: :model do
  let(:team) { Team.create(name: "Test Team", description: "A team for testing") }
  
  describe "validations" do
    context "when user is a team_member" do
      it "is invalid without a team" do
        user = User.new(
          name: "Team Member", 
          email: "team_member@example.com", 
          password: "password",
          user_type: :team_member
        )
        
        expect(user).to be_invalid
        expect(user.errors[:team_id]).to include("must be present for team members")
      end
      
      it "is valid with a team" do
        user = User.new(
          name: "Team Member", 
          email: "team_member@example.com", 
          password: "password",
          user_type: :team_member,
          team: team
        )
        
        expect(user).to be_valid
      end
    end
    
    context "when user is a judge" do
      it "is valid without a team" do
        user = User.new(
          name: "Judge", 
          email: "judge@example.com", 
          password: "password",
          user_type: :judge
        )
        
        expect(user).to be_valid
      end
      
      it "is invalid with a team" do
        user = User.new(
          name: "Judge", 
          email: "judge@example.com", 
          password: "password",
          user_type: :judge,
          team: team
        )
        
        expect(user).to be_invalid
        expect(user.errors[:team_id]).to include("must not be present for judges or admins")
      end
    end
    
    context "when user is an admin" do
      it "is valid without a team" do
        user = User.new(
          name: "Admin", 
          email: "admin@example.com", 
          password: "password",
          user_type: :admin
        )
        
        expect(user).to be_valid
      end
      
      it "is invalid with a team" do
        user = User.new(
          name: "Admin", 
          email: "admin@example.com", 
          password: "password",
          user_type: :admin,
          team: team
        )
        
        expect(user).to be_invalid
        expect(user.errors[:team_id]).to include("must not be present for judges or admins")
      end
    end
  end
end
