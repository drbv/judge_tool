class CreateRoundTypes < ActiveRecord::Migration
  def change
    create_table :round_types do |t|
      t.string :name
      t.integer :max_teams_per_round

      t.timestamps null: false
    end
  end
end
