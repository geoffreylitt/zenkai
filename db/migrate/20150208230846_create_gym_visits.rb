class CreateGymVisits < ActiveRecord::Migration
  def change
    create_table :gym_visits do |t|
      t.date "date"
      t.datetime "datetime"
    end
  end
end
