class CreateStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :sensor_statuses do |t|
      t.timestamp   :moment, index: true
      t.integer     :steps
      t.point       :position
    end
  end
end
