import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';
export default class extends Controller {
    static targets = ["notice"];

    connect() {
        // Initialize state when controller connects
        console.log("rankingsController connected");

        // Track if rankings have changed
        this.rankingsChanged = false;

        // Store initial rankings state for comparison
        this.initialRankings = this.captureCurrentRankings();

        const lists = document.querySelectorAll('.ranking-list');
        lists.forEach(list => {
            new Sortable(list, {
                animation: 150,
                ghostClass: 'ranking-item-ghost',
                onEnd: this.handleRankingChange.bind(this)
            });
        });

        // Handle main save button click
        document.getElementById('save-rankings').addEventListener('click', this.saveRankings.bind(this));

        // Handle mobile save buttons
        document.querySelectorAll('.mobile-save-button').forEach(button => {
            button.addEventListener('click', this.saveRankings.bind(this));
        });
    }

    // Capture the current state of rankings
    captureCurrentRankings() {
        const rankings = {};

        document.querySelectorAll('.ranking-column').forEach(column => {
            const category = column.dataset.category;
            rankings[category] = [];

            column.querySelectorAll('.ranking-item').forEach(item => {
                rankings[category].push(item.dataset.teamId);
            });
        });

        return JSON.stringify(rankings);
    }

    // Handle when a ranking item is moved
    handleRankingChange() {
        const currentRankings = this.captureCurrentRankings();

        // Check if rankings have changed
        if (currentRankings !== this.initialRankings) {
            this.rankingsChanged = true;
            this.enableSaveButtons();
        } else {
            this.rankingsChanged = false;
            this.disableSaveButtons();
        }
    }

    // Enable all save buttons
    enableSaveButtons() {
        document.getElementById('save-rankings').removeAttribute('disabled');
        document.querySelectorAll('.mobile-save-button').forEach(button => {
            button.removeAttribute('disabled');
        });
    }

    // Disable all save buttons
    disableSaveButtons() {
        document.getElementById('save-rankings').setAttribute('disabled', 'disabled');
        document.querySelectorAll('.mobile-save-button').forEach(button => {
            button.setAttribute('disabled', 'disabled');
        });
    }

    saveRankings() {
        const rankings = {};

        // Collect rankings from each list
        document.querySelectorAll('.ranking-column').forEach(column => {
            const category = column.dataset.category;
            rankings[category] = [];

            column.querySelectorAll('.ranking-item').forEach(item => {
                rankings[category].push(item.dataset.teamId);
            });
        });

        // Send rankings to server
        fetch('/rankings/update_rankings', {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({ rankings: rankings })
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    this.showNotice(data.notice);
                    // Update initial rankings state after successful save
                    this.initialRankings = this.captureCurrentRankings();
                    this.rankingsChanged = false;
                    this.disableSaveButtons();
                } else {
                    this.showError('Error saving rankings: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                this.showError('An error occurred while saving rankings.');
            });
    }

    showNotice(message) {
        const noticeHtml = `
            <div id="notice_explanation">
                <h2>${message}</h2>
            </div>
        `;
        this.noticeTarget.innerHTML = noticeHtml;
        
        // Auto-hide after 5 seconds
        setTimeout(() => {
            this.noticeTarget.innerHTML = '';
        }, 5000);
    }

    showError(message) {
        const errorHtml = `
            <div id="notice_explanation" class="error">
                <h2>${message}</h2>
            </div>
        `;
        this.noticeTarget.innerHTML = errorHtml;
    }
}