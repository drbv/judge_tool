class CreateDanceRoundsDanceTeams < ActiveRecord::Migration
  def change
    create_table :dance_rounds_dance_teams, id: false do |t|
      t.integer :dance_round_id
      t.integer :dance_team_id
    end
    add_index :dance_rounds_dance_teams, [:dance_round_id, :dance_team_id], name: 'dance_round_dance_team_mapping'
  end
end
