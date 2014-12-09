class CreateTableAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.integer :meetup_id
      t.integer :user_id
    end
  end
end
