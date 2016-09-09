class CreateBeamers < ActiveRecord::Migration
  def change
    create_table :beamers do |t|
      t.string :screen

      t.timestamps null: false
    end
  end
end
