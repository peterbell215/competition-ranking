import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["teamSelection"]

  connect() {
    // Initialize state when controller connects
    this.toggleTeam()
  }

  toggleTeam() {
    const isTeamMember = this.element.querySelector('#user_type_team_member').checked
    
    if (isTeamMember) {
      this.teamSelectionTarget.style.display = 'block'
    } else {
      this.teamSelectionTarget.style.display = 'none'
      // Clear the team selection if not a team member
      this.teamSelectionTarget.querySelector('select').value = ''
    }
  }
}
