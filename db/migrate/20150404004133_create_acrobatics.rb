class CreateAcrobatics < ActiveRecord::Migration
  def change
    create_table :acrobatics do |t|
      t.references :dance_team, index: true, foreign_key: true
      t.references :dance_round, index: true, foreign_key: true
      t.references :acrobatic_type, index: true, foreign_key: true
      t.integer :position
      t.timestamps null: false
    end
  end
end
