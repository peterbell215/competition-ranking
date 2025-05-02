class CreateRankings < ActiveRecord::Migration[7.0]
  def change
    create_table :rankings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :technical_merit
      t.integer :commercial_merit
      t.integer :overall_merit

      t.timestamps
    end
    
    add_index :rankings, [:user_id, :team_id], unique: true
  end
end
