class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    
    add_index :teams, :name, unique: true
  end
end
