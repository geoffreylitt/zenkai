class CreateStepsCheckins < ActiveRecord::Migration
  def change
    create_table :steps_checkins do |t|
      t.date "date"
      t.integer "n_steps"
      t.integer "modified_timestamp", limit: 8
    end
  end
end
