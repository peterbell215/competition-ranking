class ModifyRankingsWithCategoryAndMerit < ActiveRecord::Migration[8.0]
  def change
    change_table :rankings do |t|
      # Add new fields
      t.integer :category, null: false, default: 0
      t.integer :merit
      
      # Remove old merit fields
      t.remove :technical_merit
      t.remove :commercial_merit
      t.remove :overall_merit
    end
    
    # Add a new unique index for user_id, team_id, and category combination
    add_index :rankings, [:user_id, :team_id, :category], unique: true
    
    # Remove the old unique index for just user_id and team_id
    remove_index :rankings, [:user_id, :team_id]
  end
end
