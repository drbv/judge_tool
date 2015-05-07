class CreateDanceRoundMappings < ActiveRecord::Migration
  def change
    create_table :dance_round_mappings do |t|
      t.integer :dance_round_id
      t.integer :dance_team_id
      t.integer :user_id
    end
    add_index :dance_round_mappings, [:dance_round_id, :dance_team_id], name: 'dance_round_dance_team_mapping'
    add_index :dance_round_mappings, [:dance_round_id, :dance_team_id, :user_id], name: 'observer_dance_team_mapping'
  end
end