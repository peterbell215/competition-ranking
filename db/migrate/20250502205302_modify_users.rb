class ModifyUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :name, null: false
      t.integer :user_type
      t.references :team, foreign_key: true, null: true
    end
  end
end
