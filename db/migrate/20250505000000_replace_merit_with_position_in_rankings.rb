class ReplaceMeritWithPositionInRankings < ActiveRecord::Migration[8.0]
  def change
    # Rename the merit column to position
    rename_column :rankings, :merit, :position
    
    # Change the default if necessary
    # No default is currently specified in the schema for merit
  end
end
