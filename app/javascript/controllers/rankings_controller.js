import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';
export default class extends Controller {
    static targets = ["rankings"];

    connect() {
        // Initialize state when controller connects
        console.log("rankingsController connected");

        const lists = document.querySelectorAll('.ranking-list');
        lists.forEach(list => {
            new Sortable(list, {
                animation: 150,
                ghostClass: 'ranking-item-ghost'
            });
        });

        // Handle save button click
        document.getElementById('save-rankings').addEventListener('click', function() {
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
                        alert('Rankings saved successfully!');
                    } else {
                        alert('Error saving rankings: ' + data.error);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while saving rankings.');
                });
        });
    }
}