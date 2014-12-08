class CreateMeetups < ActiveRecord::Migration
  def change
    create_table :meetups do |t|
      t.string :title, null: false
      t.string :location, null: false
      t.text :description, null: false
      t.integer :created_by, null: false
      t.date :start_date, null: false
      t.time :start_time, null: false

      t.timestamps
    end
  end
end
