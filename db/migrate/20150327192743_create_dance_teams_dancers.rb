class CreateDanceTeamsDancers < ActiveRecord::Migration
  def change
    create_table :dance_teams_dancers, id: false do |t|
      t.integer :dancer_id
      t.integer :dance_team_id
    end
  end
end
