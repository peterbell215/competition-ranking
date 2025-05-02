class CreateExclusions < ActiveRecord::Migration[7.0]
  def change
    create_table :exclusions do |t|
      t.references :team, null: false, foreign_key: true
      t.references :excluded_team, null: false, foreign_key: { to_table: :teams }

      t.timestamps
    end
    
    add_index :exclusions, [:team_id, :excluded_team_id], unique: true
  end
end
