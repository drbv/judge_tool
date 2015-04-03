class CreateDanceTeams < ActiveRecord::Migration
  def change
    create_table :dance_teams do |t|
      t.references :dance_class
      t.references :club, index: true, foreign_key: true
      t.string :name
      t.integer :startnumber
      t.integer :startbook_number
      t.integer :rank
      t.integer :ranking_points

      t.timestamps null: false
    end
  end
end
