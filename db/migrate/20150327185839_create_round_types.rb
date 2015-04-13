class CreateRoundTypes < ActiveRecord::Migration
  def change
    create_table :round_types do |t|
      t.string :name
      t.string :acrobatics_from
      t.boolean :no_dance, default: false

      t.timestamps null: false
    end
  end
end
